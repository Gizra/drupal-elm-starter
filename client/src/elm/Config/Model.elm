module Config.Model exposing (BackendUrl, Model)

import Pusher.Model exposing (PusherAppKey)


type alias BackendUrl =
    String


type alias Model =
    { backendUrl : BackendUrl
    , debug : Bool
    , name : String
    , pusherKey : PusherAppKey
    }
