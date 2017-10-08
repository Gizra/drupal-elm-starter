module Pages.Item.Update exposing (update)

import App.PageType exposing (Page)
import Pages.Item.Model exposing (Msg(HandlePusherEventData, SetRedirectPage))
import Pusher.Model exposing (PusherEventData(ItemUpdate))
import Item.Model exposing (Item)


update : Msg -> Item -> ( Item, Cmd Msg, Maybe Page )
update msg item =
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
