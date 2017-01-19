module Config.Model exposing (..)

import Pusher.Model exposing (PusherAppKey)


type alias BackendUrl =
    String


type alias Model =
    { backendUrl : BackendUrl
    , name : String
    , pusherKey : PusherAppKey
    }
