module Config exposing (..)

import Config.Model as Config exposing (Model)
import Dict exposing (..)


local : Model
local =
    { backendUrl = "http://localhost/drupal-elm-starter/server/www"
    , name = "local"
    , pusherKey = ""
    }


devPantheon : Model
devPantheon =
    { backendUrl = "https://dev-drupal-elm-starter.pantheonsite.io"
    , name = "devPantheon"
    , pusherKey = ""
    }


testPantheon : Model
testPantheon =
    { backendUrl = "https://test-drupal-elm-starter.pantheonsite.io"
    , name = "testPantheon"
    , pusherKey = ""
    }


livePantheon : Model
livePantheon =
    { backendUrl = "https://live-drupal-elm-starter.pantheonsite.io"
    , name = "livePantheon"
    , pusherKey = ""
    }


configs : Dict String Model
configs =
    Dict.fromList
        [ ( "localhost", local )
        , ( "dev-drupal-elm-starter.pantheonsite.io", devPantheon )
        , ( "test-drupal-elm-starter.pantheonsite.io", testPantheon )
        , ( "live-drupal-elm-starter.pantheonsite.io", livePantheon )
        ]
