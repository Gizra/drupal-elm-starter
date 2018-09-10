module Pages.PageNotFound.View exposing (view)

import Html exposing (Html, a, div, h2, text)
import Html.Attributes exposing (class, href)
import Translate as Trans exposing (Language, translateText)



-- VIEW


view : Language -> Html a
view language =
    div [ class "ui segment center aligned" ]
        [ h2 [] [ translateText language Trans.PageNotFound ]
        ]
