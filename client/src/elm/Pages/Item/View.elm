module Pages.Item.View exposing (view)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Json.Decode
import Pages.Item.Model exposing (Model, Msg(..))
import Item.Model exposing (ItemId, Item)
import User.Model exposing (User)


view : Date -> User -> ItemId -> Item -> Model -> Html Msg
view currentDate currentUser itemId item model =
    div []
        [ div
            [ class "ui secondary pointing fluid menu" ]
          <|
            itemHeader item model
                ++ [ div
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


itemHeader : Item -> Model -> List (Html Msg)
itemHeader item model =
    case model.editingItemName of
        Just editedName ->
            [ h2 [ class "ui header input" ]
                [ input
                    [ value editedName
                    , onChange EditingNameUpdate
                    ]
                    []
                ]
            , button
                [ name "Done"
                , type_ "button"
                , onClick EditingNameFinish
                ]
                [ text "Done" ]
            , button
                [ name "Cancel"
                , type_ "button"
                , onClick EditingNameCancel
                ]
                [ text "Cancel" ]
            ]

        Nothing ->
            [ h2
                [ class "ui header" ]
                [ text item.name ]
            , button
                [ name "Edit"
                , type_ "button"
                , onClick EditingNameBegin
                ]
                [ text "Edit" ]
            ]


onChange : (String -> Msg) -> Attribute Msg
onChange tagger =
    on "change" (Json.Decode.map tagger targetValue)
