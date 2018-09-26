module Pages.Item.Model exposing (Msg(..))

import App.PageType exposing (Page(..))
import Pusher.Model exposing (PusherEventData)


type Msg
    = HandlePusherEventData PusherEventData
    | SetRedirectPage Page
