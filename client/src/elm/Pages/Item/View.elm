module Pages.Item.View exposing (view)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Item.Model exposing (Msg(..))
import Item.Model exposing (ItemId, Item)
import User.Model exposing (User)


view : Date -> User -> ItemId -> Item -> Html Msg
view currentDate currentUser itemId item =
    div []
        [ div
            [ class "ui secondary pointing fluid menu" ]
            [ h1
                [ class "ui header" ]
                [ text item.name ]
            ]
        , div []
            [ img [ src item.image ] []
            ]
        , div
            [ class "ui divider" ]
            []
        ]
