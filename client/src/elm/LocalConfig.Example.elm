module LocalConfig exposing (localConfigs)

import Config.Model exposing (Model)
import Dict exposing (Dict)
import Pusher.Model exposing (Cluster(UsEast1), PusherAppKey)


local : Model
local =
    { backendUrl = "http://localhost/drupal-elm-starter/server/www"
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
