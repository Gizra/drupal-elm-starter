port module Main exposing (allTests, emit, main)

import App.Test exposing (all)
import Json.Encode exposing (Value)
import Pages.Login.Test
import Pusher.Test exposing (all)
import Test exposing (Test, describe)
import Test.Runner.Node exposing (TestProgram, run)


allTests : Test
allTests =
    describe "All tests"
        [ App.Test.all
        , Pages.Login.Test.all
        , Pusher.Test.all
        ]


main : TestProgram
main =
    run emit allTests


port emit : ( String, Value ) -> Cmd msg
