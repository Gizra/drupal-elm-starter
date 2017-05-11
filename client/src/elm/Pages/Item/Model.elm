module Pages.Item.Model exposing (..)

import App.PageType exposing (Page(..))
import Pusher.Model exposing (PusherEventData)


type Msg
    = HandlePusherEventData PusherEventData
    | SetRedirectPage Page


type alias Model =
    {}


emptyModel : Model
emptyModel =
    {}
