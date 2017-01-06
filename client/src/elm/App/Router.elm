module App.Router exposing (delta2url, location2messages)

import App.Model exposing (..)
import App.PageType exposing (..)
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import UrlParser exposing (Parser, map, parseHash, s, oneOf, (</>), int, string)


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    case current.activePage of
        AccessDenied ->
            Nothing

        Login ->
            Just <| UrlChange NewEntry "#login"

        MyAccount ->
            Just <| UrlChange NewEntry "#my-account"

        PageNotFound ->
            Just <| UrlChange NewEntry "#404"

        Item id ->
            Just <| UrlChange NewEntry ("#item/" ++ id)

        Dashboard ->
            -- Hack to allow dashboard to change the URL.
            Just <| UrlChange NewEntry "# "


location2messages : Location -> List Msg
location2messages location =
    case UrlParser.parseHash parseUrl location of
        Just msgs ->
            [ msgs ]

        Nothing ->
            []


parseUrl : Parser (Msg -> c) c
parseUrl =
    oneOf
        [ map (SetActivePage Dashboard) (s "")
        , map (\id -> SetActivePage <| Item (toString id)) (s "item" </> int)
        , map (SetActivePage Login) (s "login")
        , map (SetActivePage MyAccount) (s "my-account")
        ]
