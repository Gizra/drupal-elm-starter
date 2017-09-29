module Config.Model exposing (BackendUrl, Model)

import Pusher.Model exposing (PusherAppKey)


type alias BackendUrl =
    String


type alias Model =
    { backendUrl : BackendUrl
    , name : String
    , pusherKey : PusherAppKey
    }
