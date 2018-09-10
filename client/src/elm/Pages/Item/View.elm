module Pages.Item.View exposing (view)

import Date exposing (Date)
import Gizra.Html exposing (showMaybe)
import Html exposing (..)
import Html.Attributes exposing (..)
import Item.Model exposing (Item, ItemId)
import Pages.Item.Model exposing (Msg(..))
import Translate as Trans exposing (Language, translateText)
import User.Model exposing (User)
import Utils.Html exposing (divider)


view : Date -> Language -> User -> ItemId -> Item -> Html Msg
view currentDate language currentUser itemId item =
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
                    [ translateText language <| Trans.Item Trans.Overview ]
                ]
            ]
        , div []
            [ img [ src item.image, alt item.name ] []
            ]
        , divider
        , privateNote
        ]
