module Pages.Item.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Item.Model exposing (Item)
import User.Model exposing (..)
import Pages.Item.Model exposing (Model, Msg(..), ItemUpdate(..))
import Pusher.Model exposing (PusherEventData(..))


update : BackendUrl -> String -> User -> Msg -> Item -> Model -> ( Model, ItemUpdate, Cmd Msg, Maybe Page )
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
                    , UpdateFromBackend newItem
                    , Cmd.none
                    , Nothing
                    )

        SetRedirectPage page ->
            ( model, NoUpdate, Cmd.none, Just page )

        EditingNameBegin ->
            ( { model | editingItemName = Just item.name }
            , NoUpdate
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
                            -- if this happens, then the view
                            -- code is broken. We can't
                            -- finish editing the name unless
                            -- we've already started!
                            item.name
            in
                ( { model | editingItemName = Nothing }
                , UpdateFromUser { item | name = newName }
                , Cmd.none
                , Nothing
                )

        EditingNameUpdate updatedName ->
            ( { model | editingItemName = Just updatedName }
            , NoUpdate
            , Cmd.none
            , Nothing
            )

        EditingNameCancel ->
            ( { model | editingItemName = Nothing }
            , NoUpdate
            , Cmd.none
            , Nothing
            )
