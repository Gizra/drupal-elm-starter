module Utils.Html exposing (divider)

import Html exposing (..)
import Html.Attributes exposing (class)


divider : Html msg
divider =
    div [ class "ui divider" ] []
