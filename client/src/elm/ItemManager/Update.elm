port module ItemManager.Update exposing (subscriptions, update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Dict exposing (Dict)
import Error.Model exposing (Error)
import Error.Utils exposing (httpError, noError, plainError)
import HttpBuilder exposing (get, withQueryParams)
import Item.Model exposing (Item, ItemId)
import ItemManager.Decoder exposing (decodeItemFromResponse, decodeItemsFromResponse)
import ItemManager.Model exposing (..)
import ItemManager.Utils exposing (..)
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (Value)
import Pages.Item.Update
import Pages.Items.Update
import Pusher.Decoder exposing (decodePusherEvent)
import Pusher.Model exposing (PusherEventData(..))
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (sendWithHandler)


update : Date -> BackendUrl -> String -> User -> Msg -> Model -> ( Model, Cmd Msg, Maybe Page, Maybe Error )
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
                    , noError
                    )

                Loading ->
                    ( model, Cmd.none, Nothing, noError )

                Failure _ ->
                    let
                        ( val, cmds ) =
                            fetchItemFromBackend backendUrl accessToken id model
                    in
                    ( val
                    , cmds
                    , Nothing
                    , noError
                    )

                Success _ ->
                    ( model, Cmd.none, Nothing, noError )

        Unsubscribe id ->
            ( { model | items = Dict.remove id model.items }
            , Cmd.none
            , Nothing
            , noError
            )

        FetchAll ->
            let
                ( val, cmds ) =
                    fetchAllItemsFromBackend backendUrl accessToken model
            in
            ( val, cmds, Nothing, noError )

        MsgPagesItem id subMsg ->
            case getItem id model of
                Success item ->
                    let
                        ( subModel, subCmd, redirectPage ) =
                            Pages.Item.Update.update backendUrl accessToken user subMsg item
                    in
                    ( { model | items = Dict.insert id (Success subModel) model.items }
                    , Cmd.map (MsgPagesItem id) subCmd
                    , redirectPage
                    , noError
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
                    ( model, Cmd.none, Nothing, noError )

        MsgPagesItems subMsg ->
            let
                ( subModel, subCmd, redirectPage ) =
                    Pages.Items.Update.update backendUrl accessToken user subMsg (unwrapItemsDict model.items) model.itemsPage
            in
            ( { model | itemsPage = subModel }
            , Cmd.map MsgPagesItems subCmd
            , redirectPage
            , noError
            )

        HandleFetchedItems (Ok items) ->
            ( { model | items = wrapItemsDict items }
            , Cmd.none
            , Nothing
            , noError
            )

        HandleFetchedItems (Err error) ->
            ( model
            , Cmd.none
            , Nothing
            , httpError "ItemManager.Update" "HandleFetchedItems" error
            )

        HandleFetchedItem itemId (Ok item) ->
            let
                -- Let Item settings fetch own data.
                -- @todo: Pass the activePage here, so we can fetch
                -- data only when really needed.
                updatedModel =
                    { model | items = Dict.insert itemId (Success item) model.items }
            in
            ( updatedModel
            , Cmd.none
            , Nothing
            , noError
            )

        HandleFetchedItem itemId (Err error) ->
            ( { model | items = Dict.insert itemId (Failure error) model.items }
            , Cmd.none
            , Nothing
            , httpError "ItemManager.Update" "HandleFetchedItem" error
            )

        HandlePusherEvent result ->
            case result of
                Ok event ->
                    case event.data of
                        ItemUpdate data ->
                            -- For now we just update the item in the items Dict. But this
                            -- can be used to pipe the pushed data to child components.
                            ( { model | items = Dict.insert event.itemId (Success data) model.items }
                            , Cmd.none
                            , Nothing
                            , noError
                            )

                Err error ->
                    ( model
                    , Cmd.none
                    , Nothing
                    , plainError "ItemManager.Update" "HandlePusherEvent" error
                    )


{-| A single port for all messages coming in from pusher for a `Item` ... they
will flow in once `subscribeItem` is called. We'll wrap the structures on
the Javascript side so that we can dispatch them from here.
-}
port pusherItemMessages : (Value -> msg) -> Sub msg


fetchItemFromBackend : BackendUrl -> String -> ItemId -> Model -> ( Model, Cmd Msg )
fetchItemFromBackend backendUrl accessToken itemId model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/items/" ++ itemId)
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeItemFromResponse (HandleFetchedItem itemId)
    in
    ( { model | items = Dict.insert itemId Loading model.items }
    , command
    )


fetchAllItemsFromBackend : BackendUrl -> String -> Model -> ( Model, Cmd Msg )
fetchAllItemsFromBackend backendUrl accessToken model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/items")
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeItemsFromResponse HandleFetchedItems
    in
    ( model
    , command
    )


subscriptions : Model -> Page -> Sub Msg
subscriptions model activePage =
    pusherItemMessages (decodeValue decodePusherEvent >> HandlePusherEvent)
