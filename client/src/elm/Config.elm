module Config exposing (..)

import Config.Model as Config exposing (Model)
import Dict exposing (..)
import Pusher.Model exposing (Cluster(..), PusherAppKey)


local : Model
local =
    { backendUrl = "http://localhost/drupal-elm-starter/server/www"
    , name = "local"
    , pusherKey = PusherAppKey "" UsEast1
    }


devPantheon : Model
devPantheon =
    { backendUrl = "https://dev-drupal-elm-starter.pantheonsite.io"
    , name = "devPantheon"
    , pusherKey = PusherAppKey "" UsEast1
    }


testPantheon : Model
testPantheon =
    { backendUrl = "https://test-drupal-elm-starter.pantheonsite.io"
    , name = "testPantheon"
    , pusherKey = PusherAppKey "" UsEast1
    }


livePantheon : Model
livePantheon =
    { backendUrl = "https://live-drupal-elm-starter.pantheonsite.io"
    , name = "livePantheon"
    , pusherKey = PusherAppKey "" UsEast1
    }


configs : Dict String Model
configs =
    Dict.fromList
        [ ( "localhost", local )
        , ( "dev-drupal-elm-starter.pantheonsite.io", devPantheon )
        , ( "test-drupal-elm-starter.pantheonsite.io", testPantheon )
        , ( "live-drupal-elm-starter.pantheonsite.io", livePantheon )
        ]
