module ItemManager.View
    exposing
        ( viewPageItem
        , viewItems
        )

import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Pages.Item.View
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Pages.Items.View
import Item.Model exposing (ItemId, ItemsDict)
import ItemManager.Model exposing (..)
import ItemManager.Utils exposing (getItem, unwrapItemsDict)
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (viewError)


{-| Show all Items page.
-}
viewItems : Date -> User -> Model -> Html Msg
viewItems currentDate user model =
    let
        items =
            unwrapItemsDict model.items
    in
        div []
            [ Html.map MsgPagesItems <| Pages.Items.View.view currentDate user items model.itemsPage
            ]


{-| Show the Item page.
-}
viewPageItem : Date -> ItemId -> User -> Model -> Html Msg
viewPageItem currentDate id user model =
    case getItem id model of
        NotAsked ->
            -- This shouldn't happen, but if it does, we provide
            -- a button to load the editor
            div
                [ class "ui button"
                , onClick <| Subscribe id
                ]
                [ text "Re-load Item" ]

        Loading ->
            div [] []

        Failure error ->
            div []
                [ viewError error
                , div
                    [ class "ui button"
                    , onClick <| Subscribe id
                    ]
                    [ text "Retry" ]
                ]

        Success item ->
            div []
                [ Html.map (MsgPagesItem id) <| Pages.Item.View.view currentDate user id item ]
