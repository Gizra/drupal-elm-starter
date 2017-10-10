module LocalConfig exposing (localConfigs)

import Config.Model as Config exposing (Model)
import Dict exposing (..)
import Pusher.Model exposing (Cluster(..), PusherAppKey)


local : Model
local =
    { backendUrl = "http://localhost/drupal-elm-starter/server/www"
    , debug = True
    , name = "local"
    , pusherKey = PusherAppKey "" UsEast1
    }


localConfigs : Dict String Model
localConfigs =
    Dict.fromList
        -- Change "localhost" if you are serving this from a different local
        -- URL.
        [ ( "localhost", local )
        ]
