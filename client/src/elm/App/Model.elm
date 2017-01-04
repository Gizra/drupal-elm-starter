module App.Model exposing (emptyModel, Flags, Msg(..), Model)

import App.PageType exposing (Page(..))
import Config.Model
import Date exposing (Date)
import Pages.Login.Model exposing (emptyModel, Model)
import RemoteData exposing (RemoteData(..), WebData)
import ItemManager.Model exposing (emptyModel, Model)
import Time exposing (Time)
import User.Model exposing (..)


type Msg
    = HandleOfflineEvent (Result String Bool)
    | Logout
    | MsgItemManager ItemManager.Model.Msg
    | PageLogin Pages.Login.Model.Msg
    | SetActivePage Page
    | SetCurrentDate Date
    | Tick Time


type alias Model =
    { accessToken : String
    , activePage : Page
    , config : RemoteData String Config.Model.Model
    , currentDate : Date
    , offline : Bool
    , pageLogin : Pages.Login.Model.Model
    , pageItem : ItemManager.Model.Model
    , user : WebData User
    }


type alias Flags =
    { accessToken : String
    , hostname : String
    }


emptyModel : Model
emptyModel =
    { accessToken = ""
    , activePage = Login
    , config = NotAsked
    , currentDate = Date.fromTime 0
    , offline = False
    , pageLogin = Pages.Login.Model.emptyModel
    , pageItem = ItemManager.Model.emptyModel
    , user = NotAsked
    }
