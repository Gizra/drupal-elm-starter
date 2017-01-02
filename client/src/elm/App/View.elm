module App.View exposing (..)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import Config.View
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, src, style, target)
import Html.Events exposing (onClick)
import User.Model exposing (..)
import Pages.Login.View exposing (..)
import Pages.MyAccount.View exposing (..)
import Pages.PageNotFound.View exposing (..)
import SensorManager.View exposing (..)
import SensorManager.Utils exposing (unwrapSensorsDict)
import RemoteData exposing (RemoteData(..), WebData)


view : Model -> Html Msg
view model =
    case model.config of
        Failure err ->
            Config.View.view

        _ ->
            div []
                [ div [ class "ui container main" ]
                    [ viewSidebar model
                    , div
                        [ class "pusher" ]
                        [ div
                            [ class "ui grid container" ]
                            [ div
                                [ class "ui main grid" ]
                                [ viewMainContent model ]
                            ]
                        ]
                    ]
                ]


viewSidebar : Model -> Html Msg
viewSidebar model =
    case model.user of
        Success user ->
            div
                [ class "ui visible sidebar inverted vertical menu" ]
                [ a
                    [ class "item"
                    , onClick <| SetActivePage MyAccount
                    ]
                    [ h4
                        [ class "ui grey header" ]
                        [ text user.name ]
                    ]
                , a
                    [ class "item"
                    , onClick Logout
                    ]
                    [ text "Sign Out" ]
                , a
                    [ class "item"
                    , onClick <| SetActivePage Sensors
                    ]
                    [ text "Dashboard"
                    ]
                , a
                    [ class "item"
                    , onClick <| SetActivePage Sensors
                    ]
                    [ text "Sensors" ]
                ]

        _ ->
            div [] []


navbarAnonymous : Model -> List (Html Msg)
navbarAnonymous model =
    [ a
        [ classByPage Login model.activePage
        , onClick <| SetActivePage Login
        ]
        [ text "Login" ]
    , viewPageNotFoundItem model.activePage
    ]


navbarAuthenticated : Model -> List (Html Msg)
navbarAuthenticated model =
    [ a
        [ classByPage MyAccount model.activePage
        , onClick <| SetActivePage MyAccount
        ]
        [ text "My Account" ]
    , viewPageNotFoundItem model.activePage
    , div [ class "right menu" ]
        [ viewAvatar model.user
        , a
            [ class "ui item"
            , onClick <| Logout
            ]
            [ text "Logout" ]
        ]
    ]


viewPageNotFoundItem : Page -> Html Msg
viewPageNotFoundItem activePage =
    a
        [ classByPage PageNotFound activePage
        , onClick <| SetActivePage PageNotFound
        ]
        [ text "404 page" ]


viewAvatar : WebData User -> Html Msg
viewAvatar user =
    case user of
        Success user_ ->
            a
                [ onClick <| SetActivePage MyAccount
                , class "ui item"
                ]
                [ img
                    [ class "ui avatar image"
                    , src user_.avatarUrl
                    ]
                    []
                ]

        _ ->
            div [] []


viewMainContent : Model -> Html Msg
viewMainContent model =
    let
        backendUrl =
            case model.config of
                Success config ->
                    config.backendUrl

                _ ->
                    ""
    in
        case model.activePage of
            AccessDenied ->
                div [] [ text "Access denied" ]

            Login ->
                Html.map PageLogin (Pages.Login.View.view model.user model.pageLogin)

            MyAccount ->
                Pages.MyAccount.View.view model.user

            PageNotFound ->
                -- We don't need to pass any cmds, so we can call the view directly
                Pages.PageNotFound.View.view

            Sensors ->
                -- We get the user information before diving down a level, since
                -- Pages.LiveSession can't do anything sensible without a user, and it is
                -- at this higher level that we could present a UI related to loading
                -- the user information.
                case model.user of
                    Success user ->
                        Html.map MsgSensorManager <|
                            SensorManager.View.viewSensors model.currentDate user model.pageSensor

                    _ ->
                        div []
                            [ i [ class "notched circle loading icon" ] [] ]

            PageSensor id ->
                -- We get the user information before diving down a level, since
                -- Pages.LiveSession can't do anything sensible without a user, and it is
                -- at this higher level that we could present a UI related to loading
                -- the user information.
                case model.user of
                    Success user ->
                        Html.map MsgSensorManager <|
                            SensorManager.View.viewPageSensor model.currentDate id user model.pageSensor

                    _ ->
                        div []
                            [ i [ class "notched circle loading icon" ] [] ]


{-| Get menu items classes. This function gets the active page and checks if
it is indeed the page used.
-}
classByPage : Page -> Page -> Attribute a
classByPage page activePage =
    classList
        [ ( "item", True )
        , ( "active", page == activePage )
        ]
