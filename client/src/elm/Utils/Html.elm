module Utils.Html exposing (divider, emptyNode, showMaybe)

import Html exposing (div, Html, text)
import Html.Attributes exposing (class)


divider : Html msg
divider =
    div [ class "ui divider" ] []


emptyNode : Html msg
emptyNode =
    text ""


{-| Show Maybe Html if Just, or empty node if Nothing.
-}
showMaybe : Maybe (Html msg) -> Html msg
showMaybe =
    Maybe.withDefault emptyNode
