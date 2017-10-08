module Pages.PageNotFound.View exposing (view)

import Html exposing (div, h2, text, Html)
import Html.Attributes exposing (class)


-- VIEW


view : Html a
view =
    div [ class "ui segment center aligned" ]
        [ h2 [] [ text "Sorry, nothing found in this URL." ]
        ]
