module Pusher.Test exposing (all)

import Date
import Dict
import Expect
import Json.Decode exposing (decodeString)
import Pusher.Decoder exposing (..)
import Pusher.Model exposing (..)
import Test exposing (Test, describe, test)


decodeTest : Test
decodeTest =
    describe "Decode Pusher"
        [ test "valid json" <|
            \() ->
                let
                    json =
                        """
{
    "eventType" : "sensor__update",
    "data" : {
      "label" : "new-sensor"
    }

}
            """

                    expectedResult =
                        { sensorId = "100"
                        , data =
                            { name = "new-sensor"
                            , image = "http://placehold.it/350x150"
                            }
                                |> SensorUpdate
                        }
                in
                    Expect.equal (Ok expectedResult) (decodeString decodePusherEvent json)
        ]


all : Test
all =
    describe "Pusher tests"
        [ decodeTest
        ]
