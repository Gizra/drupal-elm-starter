module Pages.Item.View exposing (view)

import Html exposing (a, div, Html, h2, img, text)
import Html.Attributes exposing (alt, class, src)
import Pages.Item.Model exposing (Msg)
import Item.Model exposing (Item)
import Utils.Html exposing (divider, showMaybe)


view : Item -> Html Msg
view item =
    let
        privateNote =
            showMaybe <|
                Maybe.map
                    (\note -> div [ class "private-note" ] [ text note ])
                    item.privateNote
    in
        div []
            [ div
                [ class "ui secondary pointing fluid menu" ]
                [ h2
                    [ class "ui header" ]
                    [ text item.name ]
                , div
                    [ class "right menu" ]
                    [ a
                        [ class "ui active item" ]
                        [ text "Overview" ]
                    ]
                ]
            , div []
                [ img [ src item.image, alt item.name ] []
                ]
            , divider
            , privateNote
            ]
