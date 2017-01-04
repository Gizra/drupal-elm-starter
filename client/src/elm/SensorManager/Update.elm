port module ItemManager.Update exposing (update, subscriptions)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (Value)
import HttpBuilder exposing (get, withQueryParams)
import Pages.Item.Model
import Pages.Item.Update
import Pages.Hedley.Update
import Item.Model exposing (Item, ItemId)
import ItemManager.Decoder exposing (decodeItemFromResponse, decodeHedleyFromResponse)
import ItemManager.Model exposing (..)
import ItemManager.Utils exposing (..)
import Pusher.Decoder exposing (decodePusherEvent)
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (sendWithHandler)


update : Date -> BackendUrl -> String -> User -> Msg -> Model -> ( Model, Cmd Msg, Maybe Page )
update currentDate backendUrl accessToken user msg model =
    case msg of
        Subscribe id ->
            -- Note that we're waiting to get the response from the server
            -- before we subscribe to the Pusher events.
            case getItem id model of
                NotAsked ->
                    let
                        ( updatedModel, updatedCmds ) =
                            fetchItemFromBackend backendUrl accessToken id model
                    in
                        ( updatedModel
                        , updatedCmds
                        , Nothing
                        )

                Loading ->
                    ( model, Cmd.none, Nothing )

                Failure _ ->
                    let
                        ( val, cmds ) =
                            fetchItemFromBackend backendUrl accessToken id model
                    in
                        ( val
                        , cmds
                        , Nothing
                        )

                Success _ ->
                    ( model, Cmd.none, Nothing )

        Unsubscribe id ->
            ( { model | hedley = Dict.remove id model.hedley }
            , Cmd.none
            , Nothing
            )

        FetchAll ->
            let
                ( val, cmds ) =
                    fetchAllHedleyFromBackend backendUrl accessToken model
            in
                ( val, cmds, Nothing )

        MsgPagesItem id subMsg ->
            case getItem id model of
                Success item ->
                    let
                        ( subModel, subCmd, redirectPage ) =
                            Pages.Item.Update.update backendUrl accessToken user subMsg item
                    in
                        ( { model | hedley = Dict.insert id (Success subModel) model.hedley }
                        , Cmd.map (MsgPagesItem id) subCmd
                        , redirectPage
                        )

                _ ->
                    -- We've received a message for a Item which we either
                    -- aren't subscribed to, or dont' have initial data for yet.
                    -- This normally wouldn't happen, though we may needd to think
                    -- about synchronization between obtaining our initial data and
                    -- possible "pusher" messages. (Could pusher messages sometimes
                    -- arrive before the initial data, and if so, should we ignore
                    -- them or queue them up? We may need server timestamps on the initial
                    -- data and the pusher messages to know.)
                    ( model, Cmd.none, Nothing )

        MsgPagesHedley subMsg ->
            let
                ( subModel, subCmd, redirectPage ) =
                    Pages.Hedley.Update.update backendUrl accessToken user subMsg (unwrapHedleyDict model.hedley) model.hedleyPage
            in
                ( { model | hedleyPage = subModel }
                , Cmd.map MsgPagesHedley subCmd
                , redirectPage
                )

        HandleFetchedHedley (Ok hedley) ->
            ( { model | hedley = wrapHedleyDict hedley }
            , Cmd.none
            , Nothing
            )

        HandleFetchedHedley (Err err) ->
            ( model, Cmd.none, Nothing )

        HandleFetchedItem itemId (Ok item) ->
            let
                -- Let Item settings fetch own data.
                -- @todo: Pass the activePage here, so we can fetch
                -- data only when really needed.
                updatedModel =
                    { model | hedley = Dict.insert itemId (Success item) model.hedley }
            in
                ( updatedModel
                , Cmd.none
                , Nothing
                )

        HandleFetchedItem itemId (Err err) ->
            ( { model | hedley = Dict.insert itemId (Failure err) model.hedley }
            , Cmd.none
            , Nothing
            )

        HandlePusherEvent result ->
            case result of
                Ok event ->
                    let
                        subMsg =
                            Pages.Item.Model.HandlePusherEventData event.data
                    in
                        update currentDate backendUrl accessToken user (MsgPagesItem event.itemId subMsg) model

                Err err ->
                    let
                        _ =
                            Debug.log "Pusher decode Err" err
                    in
                        -- We'll log the error decoding the pusher event
                        ( model, Cmd.none, Nothing )


{-| A single port for all messages coming in from pusher for a `Item` ... they
will flow in once `subscribeItem` is called. We'll wrap the structures on
the Javascript side so that we can dispatch them from here.
-}
port pusherItemMessages : (Value -> msg) -> Sub msg


fetchItemFromBackend : BackendUrl -> String -> ItemId -> Model -> ( Model, Cmd Msg )
fetchItemFromBackend backendUrl accessToken itemId model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/hedley/" ++ itemId)
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeItemFromResponse (HandleFetchedItem itemId)
    in
        ( { model | hedley = Dict.insert itemId Loading model.hedley }
        , command
        )


fetchAllHedleyFromBackend : BackendUrl -> String -> Model -> ( Model, Cmd Msg )
fetchAllHedleyFromBackend backendUrl accessToken model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/hedley")
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeHedleyFromResponse HandleFetchedHedley
    in
        -- @todo: Move WebData to wrap dict?
        ( model
        , command
        )


subscriptions : Model -> Page -> Sub Msg
subscriptions model activePage =
    pusherItemMessages (decodeValue decodePusherEvent >> HandlePusherEvent)
