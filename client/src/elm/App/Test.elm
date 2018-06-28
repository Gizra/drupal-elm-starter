module App.Test exposing (all)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import App.Update exposing (..)
import App.View exposing (view)
import Error.Utils exposing (plainError)
import Expect
import Fixtures exposing (exampleModel)
import Http
import Maybe.Extra exposing (unwrap)
import RemoteData exposing (RemoteData(..))
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (class, tag, text)


setActivePageTest : Test
setActivePageTest =
    describe "SetActivePage msg"
        [ test "set new active page" <|
            \() ->
                Expect.equal PageNotFound (getPageAsAnonymous PageNotFound)
        , test "set Login page for anonymous user" <|
            \() ->
                Expect.equal Login (getPageAsAnonymous Login)
        , test "set My account page for anonymous user" <|
            \() ->
                Expect.equal AccessDenied (getPageAsAnonymous MyAccount)
        , test "set Login page for authenticated user" <|
            \() ->
                Expect.equal AccessDenied (getPageAsAuthenticated Login)
        , test "set My account page for authenticated user" <|
            \() ->
                Expect.equal MyAccount (getPageAsAuthenticated MyAccount)
        ]


getPageAsAnonymous : Page -> Page
getPageAsAnonymous page =
    update (SetActivePage page) { exampleModel | user = Failure Http.NetworkError }
        |> Tuple.first
        |> .activePage


getPageAsAuthenticated : Page -> Page
getPageAsAuthenticated page =
    update (SetActivePage page) exampleModel
        |> Tuple.first
        |> .activePage


viewConfigErrorTest : Test
viewConfigErrorTest =
    describe "Config error view"
        [ test "Correct error message appears when config has errored" <|
            \() ->
                view { exampleModel | config = Failure "some error" }
                    |> Query.fromHtml
                    |> Query.has [ text "Configuration error" ]
        ]


viewDebugErrorTest : Test
viewDebugErrorTest =
    let
        errors =
            unwrap [] (\error -> [ error ]) (plainError "module" "location" "error message")

        modelWithDebug =
            { exampleModel
                | config = RemoteData.map (\config -> { config | debug = True }) exampleModel.config
                , errors = errors
            }

        modelWithoutDebug =
            { exampleModel
                | config = RemoteData.map (\config -> { config | debug = False }) exampleModel.config
                , errors = errors
            }
    in
    describe "Development errors appear on Debug mode"
        [ test "no errors in enabled debug mode" <|
            \() ->
                view { modelWithDebug | errors = [] }
                    |> Query.fromHtml
                    |> Query.hasNot [ class "debug-errors" ]
        , test "no errors in enabled debug mode" <|
            \() ->
                view { modelWithoutDebug | errors = [] }
                    |> Query.fromHtml
                    |> Query.hasNot [ class "debug-errors" ]
        , test "errors in enabled debug mode" <|
            \() ->
                view modelWithDebug
                    |> Query.fromHtml
                    |> Query.has [ class "debug-errors" ]
        , test "errors in disabled debug mode" <|
            \() ->
                view modelWithoutDebug
                    |> Query.fromHtml
                    |> Query.hasNot [ class "debug-errors" ]
        ]


all : Test
all =
    describe "App tests"
        [ setActivePageTest
        , viewConfigErrorTest
        , viewDebugErrorTest
        ]
