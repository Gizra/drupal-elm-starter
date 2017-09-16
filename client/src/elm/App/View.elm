module App.View exposing (..)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import Config.View
import Html exposing (..)
import Html.Attributes exposing (alt, class, classList, src)
import Html.Events exposing (onClick)
import User.Model exposing (..)
import Pages.Login.View exposing (..)
import Pages.MyAccount.View exposing (..)
import Pages.PageNotFound.View exposing (..)
import ItemManager.View exposing (..)
import RemoteData exposing (RemoteData(..))
import Utils.Html exposing (emptyNode)


view : Model -> Html Msg
view model =
    case model.config of
        Failure _ ->
            Config.View.view

        _ ->
            case model.activePage of
                Login ->
                    viewMainContent model

                _ ->
                    let
                        mainAttributes =
                            if model.sidebarOpen then
                                [ class "pusher dimmed"
                                , onClick ToggleSideBar
                                ]
                            else
                                [ class "pusher"
                                ]
                    in
                        div [ class "pushable" ]
                            -- Sidebar menu - responsive only
                            [ viewSidebar model Top
                            , div
                                mainAttributes
                                [ div
                                    [ class "ui grid container" ]
                                    -- Non-responsive menu
                                    [ viewSidebar model Left
                                    , div
                                        [ class "ui main grid" ]
                                        [ viewTopMenu
                                        , viewMainContent model
                                        ]
                                    ]
                                ]
                            ]


{-| Responsive top menu.
-}
viewTopMenu : Html Msg
viewTopMenu =
    div
        [ class "ui fixed inverted main menu" ]
        [ div
            [ class "ui container" ]
            [ a
                [ class "launch icon item sidebar-toggle"
                , onClick ToggleSideBar
                ]
                [ i [ class "sidebar icon" ] []
                ]
            ]
        ]


viewSidebar : Model -> Sidebar -> Html Msg
viewSidebar model sidebar =
    case model.user of
        Success user ->
            let
                wrapperClasses =
                    case sidebar of
                        Top ->
                            let
                                visibleClass =
                                    if model.sidebarOpen then
                                        " visible"
                                    else
                                        ""
                            in
                                String.concat [ "ui sidebar inverted vertical menu", visibleClass ]

                        Left ->
                            "ui left fixed vertical inverted menu"
            in
                div
                    [ class wrapperClasses ]
                    [ a
                        [ class "item"
                        , onClick <| SetActivePage MyAccount
                        ]
                        [ h4
                            [ class "ui grey header" ]
                            [ viewAvatar user
                            , text user.name
                            ]
                        ]
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
                    , a
                        [ class "item"
                        , onClick Logout
                        ]
                        [ text "Sign Out" ]
                    ]

        _ ->
            emptyNode


viewPageNotFoundItem : Page -> Html Msg
viewPageNotFoundItem activePage =
    a
        [ classByPage PageNotFound activePage
        , onClick <| SetActivePage PageNotFound
        ]
        [ text "404 page" ]


viewAvatar : User -> Html Msg
viewAvatar user =
    img
        [ class "ui avatar image"
        , src user.avatarUrl
        , alt "User avatar"
        ]
        []


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
                        Success _ ->
                            Html.map MsgItemManager <|
                                ItemManager.View.viewItems model.pageItem

                        _ ->
                            div []
                                [ i [ class "notched circle loading icon" ] [] ]

                Item id ->
                    -- We get the user information before diving down a level, since
                    -- Pages.LiveSession can't do anything sensible without a user, and it is
                    -- at this higher level that we could present a UI related to loading
                    -- the user information.
                    case model.user of
                        Success _ ->
                            Html.map MsgItemManager <|
                                ItemManager.View.viewPageItem id model.pageItem

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
