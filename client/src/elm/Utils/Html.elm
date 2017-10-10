module Utils.Html
    exposing
        ( divider
        , emptyNode
        , showIf
        , showMaybe
        )

import Html exposing (..)
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


{-| Conditionally show Html. A bit cleaner than using if expressions in middle
of an html block:
showIf True <| text "I'm shown"
showIf False <| text "I'm not shown"
-}
showIf : Bool -> Html msg -> Html msg
showIf condition html =
    if condition then
        html
    else
        emptyNode
