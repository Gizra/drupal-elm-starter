module Pages.Item.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Item.Model exposing (Item)
import Pages.Item.Model exposing (Msg(..))
import Pusher.Model exposing (PusherEventData(..))
import User.Model exposing (..)


update : BackendUrl -> String -> User -> Msg -> Item -> ( Item, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg item =
    case msg of
        HandlePusherEventData event ->
            case event of
                ItemUpdate newItem ->
                    -- So, the idea is that we have a new or updated item,
                    -- which has already been saved at the server. Note that
                    -- we may have just pushed this change ourselves, so it's
                    -- already reflected here.
                    ( newItem
                    , Cmd.none
                    , Nothing
                    )

        SetRedirectPage page ->
            ( item, Cmd.none, Just page )
