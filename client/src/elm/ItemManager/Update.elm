port module ItemManager.Update exposing (update, subscriptions)

import App.PageType exposing (Page)
import Config.Model exposing (BackendUrl)
import Dict
import Item.Model exposing (ItemId)
import ItemManager.Decoder exposing (decodeItemFromResponse, decodeItemsFromResponse)
import ItemManager.Model
    exposing
        ( Model
        , Msg
            ( FetchAll
            , HandleFetchedItem
            , HandleFetchedItems
            , HandlePusherEvent
            , MsgPagesItem
            , MsgPagesItems
            , Subscribe
            , Unsubscribe
            )
        )
import ItemManager.Utils exposing (getItem, wrapItemsDict)
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (Value)
import HttpBuilder exposing (withQueryParams)
import Pages.Item.Update
import Pages.Items.Update
import Pusher.Decoder exposing (decodePusherEvent)
import Pusher.Model exposing (PusherEventData(ItemUpdate))
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success))
import Utils.WebData exposing (sendWithHandler)


update : BackendUrl -> String -> Msg -> Model -> ( Model, Cmd Msg, Maybe Page )
update backendUrl accessToken msg model =
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
            ( { model | items = Dict.remove id model.items }
            , Cmd.none
            , Nothing
            )

        FetchAll ->
            let
                ( val, cmds ) =
                    fetchAllItemsFromBackend backendUrl accessToken model
            in
                ( val, cmds, Nothing )

        MsgPagesItem id subMsg ->
            case getItem id model of
                Success item ->
                    let
                        ( subModel, subCmd, redirectPage ) =
                            Pages.Item.Update.update subMsg item
                    in
                        ( { model | items = Dict.insert id (Success subModel) model.items }
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

        MsgPagesItems subMsg ->
            let
                ( subModel, subCmd, redirectPage ) =
                    Pages.Items.Update.update subMsg model.itemsPage
            in
                ( { model | itemsPage = subModel }
                , Cmd.map MsgPagesItems subCmd
                , redirectPage
                )

        HandleFetchedItems (Ok items) ->
            ( { model | items = wrapItemsDict items }
            , Cmd.none
            , Nothing
            )

        HandleFetchedItems (Err _) ->
            ( model, Cmd.none, Nothing )

        HandleFetchedItem itemId (Ok item) ->
            let
                -- Let Item settings fetch own data.
                updatedModel =
                    { model | items = Dict.insert itemId (Success item) model.items }
            in
                ( updatedModel
                , Cmd.none
                , Nothing
                )

        HandleFetchedItem itemId (Err err) ->
            ( { model | items = Dict.insert itemId (Failure err) model.items }
            , Cmd.none
            , Nothing
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
                            )

                Err _ ->
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
subscriptions _ _ =
    pusherItemMessages (decodeValue decodePusherEvent >> HandlePusherEvent)
