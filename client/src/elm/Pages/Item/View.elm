module Pages.Item.View exposing (view)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Item.Model exposing (Model, Msg(..))
import Item.Model exposing (ItemId, Item)
import User.Model exposing (User)


view : Date -> User -> ItemId -> Item -> Model -> Html Msg
view currentDate currentUser itemId item model =
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
        , div
            [ class "ui divider" ]
            []
        ]
