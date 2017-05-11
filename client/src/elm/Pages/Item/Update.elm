module Pages.Item.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Item.Model exposing (Item)
import User.Model exposing (..)
import Pages.Item.Model exposing (Model, Msg(..))
import Pusher.Model exposing (PusherEventData(..))


update : BackendUrl -> String -> User -> Msg -> Item -> Model -> ( Model, Item, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg item model =
    case msg of
        HandlePusherEventData event ->
            case event of
                ItemUpdate newItem ->
                    -- So, the idea is that we have a new or updated item,
                    -- which has already been saved at the server. Note that
                    -- we may have just pushed this change ourselves, so it's
                    -- already reflected here.
                    ( model
                    , newItem
                    , Cmd.none
                    , Nothing
                    )

        SetRedirectPage page ->
            ( model, item, Cmd.none, Just page )

        EditingNameBegin ->
            ( { model | editingItemName = Just item.name }
            , item
            , Cmd.none
            , Nothing
            )

        EditingNameFinish ->
            let
                newName =
                    case model.editingItemName of
                        Just name ->
                            name

                        Nothing ->
                            -- this case shouldn't be
                            -- possible!
                            item.name
            in
                ( { model | editingItemName = Nothing }
                , { item | name = newName }
                , Cmd.none
                , Nothing
                )

        EditingNameUpdate updatedName ->
            ( { model | editingItemName = Just updatedName }
            , item
            , Cmd.none
            , Nothing
            )

        EditingNameCancel ->
            ( { model | editingItemName = Nothing }
            , item
            , Cmd.none
            , Nothing
            )
