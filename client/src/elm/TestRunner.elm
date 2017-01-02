port module Main exposing (..)

import App.Test exposing (all)
import Factor.Test exposing (all)
import Json.Encode exposing (Value)
import Incident.Test exposing (all)
import Pusher.Test exposing (all)
import Test exposing (Test, describe)
import Test.Runner.Node exposing (TestProgram, run)


allTests : Test
allTests =
    describe "All tests"
        [ App.Test.all
        , Factor.Test.all
        , Incident.Test.all
        , Pusher.Test.all
        ]


main : TestProgram
main =
    run emit allTests


port emit : ( String, Value ) -> Cmd msg
