module Pusher.Test exposing (all)

import Date
import Dict
import DispatchMessage.Model
import Expect
import Json.Decode exposing (decodeString)
import Incident.Model exposing (..)
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
    "eventType" : "sensor__create",
    "data" : {
        "sensor": "100",
        "incidents" : {
            "2" : {
                "type" : "non_responsive",
                "status": "resolved",
                "created": "2016-12-13T11:32:54+02:00"
            }
        }
    }

}
            """

                    expectedResult =
                        { sensorId = "100"
                        , data =
                            Dict.fromList
                                [ ( "2"
                                  , { bundle = IncidentNonResponsive
                                    , status = IncidentStatusResolved
                                    , created = Date.fromTime 1481621574000
                                    , showSendTextMessage = False
                                    , dispatchMessage = DispatchMessage.Model.emptyModel
                                    }
                                  )
                                ]
                                |> PusherEventIncidentData
                                |> PusherEventIncident
                        }
                in
                    Expect.equal (Ok expectedResult) (decodeString decodePusherEvent json)
        ]


all : Test
all =
    describe "Pusher tests"
        [ decodeTest
        ]
