module Pages.Item.Model exposing (..)

import App.PageType exposing (Page(..))
import Pusher.Model exposing (PusherEventData)


type Msg
    = HandlePusherEventData PusherEventData
    | SetRedirectPage Page
    | EditingNameBegin
    | EditingNameUpdate String
    | EditingNameFinish
    | EditingNameCancel


type alias Model =
    { editingItemName : Maybe String }


emptyModel : Model
emptyModel =
    { editingItemName = Nothing }
