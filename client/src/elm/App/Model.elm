module App.Model exposing (emptyModel, Flags, Msg(..), Model)

import App.PageType exposing (Page(..))
import Config.Model
import Date exposing (Date)
import Pages.Login.Model exposing (emptyModel, Model)
import RemoteData exposing (RemoteData(..), WebData)
import SensorManager.Model exposing (emptyModel, Model)
import Time exposing (Time)
import User.Model exposing (..)


type Msg
    = Logout
    | MsgSensorManager SensorManager.Model.Msg
    | PageLogin Pages.Login.Model.Msg
    | SetActivePage Page
    | SetCurrentDate Date
    | Tick Time


type alias Model =
    { accessToken : String
    , activePage : Page
    , config : RemoteData String Config.Model.Model
    , currentDate : Date
    , pageLogin : Pages.Login.Model.Model
    , pageSensor : SensorManager.Model.Model
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
    , pageLogin = Pages.Login.Model.emptyModel
    , pageSensor = SensorManager.Model.emptyModel
    , user = NotAsked
    }
