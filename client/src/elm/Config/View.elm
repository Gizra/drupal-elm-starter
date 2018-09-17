module Config.View exposing (view)

import Html exposing (Html, div, h2, text)
import Html.Attributes exposing (class)



-- A plain function that always returns the error message


view : Html msg
view =
    div
        [ class "config-error" ]
        [ h2 [] [ text "Configuration error" ]
        , div [] [ text "Check your LocalConfig.elm or Config.elm file and make sure you have defined the environment properly" ]
        ]
