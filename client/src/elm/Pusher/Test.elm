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
    "eventType" : "item__update",
    "data" : {
      "id" : "100",
      "label" : "new-item"
    }

}
            """

                    expectedResult =
                        { itemId = "100"
                        , data =
                            { name = "new-item"
                            , image = "http://placehold.it/350x150"
                            , privateNote = Nothing
                            }
                                |> ItemUpdate
                        }
                in
                Expect.equal (Ok expectedResult) (decodeString decodePusherEvent json)
        ]


all : Test
all =
    describe "Pusher tests"
        [ decodeTest
        ]
