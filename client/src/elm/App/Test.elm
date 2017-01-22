module App.Test exposing (all)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import App.Update exposing (..)
import App.View exposing (view)
import Expect
import Http
import Test exposing (describe, test, Test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag)
import RemoteData exposing (RemoteData(..))


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
    update (SetActivePage page) { emptyModel | user = Failure Http.NetworkError }
        |> Tuple.first
        |> .activePage


getPageAsAuthenticated : Page -> Page
getPageAsAuthenticated page =
    let
        dummyUser =
            { id = 100, name = "Foo", avatarUrl = "https://example.com" }

        model =
            { emptyModel | user = Success dummyUser }
    in
        update (SetActivePage page) model
            |> Tuple.first
            |> .activePage


viewConfigErrorTest : Test
viewConfigErrorTest =
    describe "Config error view"
        [ test "Correct error message appears when config has errored" <|
            \() ->
                view { emptyModel | config = Failure "some error" }
                    |> Query.fromHtml
                    |> Query.has [ text "Configuration error" ]
        ]


all : Test
all =
    describe "App tests"
        [ setActivePageTest
        , viewConfigErrorTest
        ]
