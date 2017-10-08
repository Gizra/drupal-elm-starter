module Config exposing (configs)

import Config.Model exposing (Model)
import Dict exposing (Dict)
import LocalConfig exposing (localConfigs)
import Pusher.Model exposing (Cluster(UsEast1), PusherAppKey)


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
        [ ( "dev-drupal-elm-starter.pantheonsite.io", devPantheon )
        , ( "test-drupal-elm-starter.pantheonsite.io", testPantheon )
        , ( "live-drupal-elm-starter.pantheonsite.io", livePantheon )
        ]
        |> Dict.union localConfigs
