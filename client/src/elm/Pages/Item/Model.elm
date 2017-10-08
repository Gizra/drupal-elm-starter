module Pages.Item.Model exposing (Msg(HandlePusherEventData, SetRedirectPage))

import App.PageType exposing (Page)
import Pusher.Model exposing (PusherEventData)


type Msg
    = HandlePusherEventData PusherEventData
    | SetRedirectPage Page
