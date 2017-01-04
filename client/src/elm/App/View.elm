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
import ItemManager.View exposing (..)
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
                                [ viewMainContent model
                                ]
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
                    , onClick <| SetActivePage Dashboard
                    ]
                    [ text "Dashboard" ]
                , span
                    [ class "item"
                    ]
                    [ text <|
                        if model.offline then
                            "Not Connected"
                        else
                            "Connected"
                    , i
                        [ classList
                            [ ( "icon wifi", True )
                            , ( "disabled", model.offline )
                            ]
                        ]
                        []
                    ]
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
        viewContent =
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

                Dashboard ->
                    -- We get the user information before diving down a level, since
                    -- Pages.LiveSession can't do anything sensible without a user, and it is
                    -- at this higher level that we could present a UI related to loading
                    -- the user information.
                    case model.user of
                        Success user ->
                            Html.map MsgItemManager <|
                                ItemManager.View.viewItems model.currentDate user model.pageItem

                        _ ->
                            div []
                                [ i [ class "notched circle loading icon" ] [] ]

                Item id ->
                    -- We get the user information before diving down a level, since
                    -- Pages.LiveSession can't do anything sensible without a user, and it is
                    -- at this higher level that we could present a UI related to loading
                    -- the user information.
                    case model.user of
                        Success user ->
                            Html.map MsgItemManager <|
                                ItemManager.View.viewPageItem model.currentDate id user model.pageItem

                        _ ->
                            div []
                                [ i [ class "notched circle loading icon" ] [] ]
    in
        case model.user of
            NotAsked ->
                if String.isEmpty model.accessToken then
                    viewContent
                else
                    -- User might be logged in, so no need to present the login form.
                    -- So we first just show a throbber
                    div []
                        [ i [ class "icon loading spinner" ] []
                        ]

            _ ->
                viewContent


{-| Get menu items classes. This function gets the active page and checks if
it is indeed the page used.
-}
classByPage : Page -> Page -> Attribute a
classByPage page activePage =
    classList
        [ ( "item", True )
        , ( "active", page == activePage )
        ]
