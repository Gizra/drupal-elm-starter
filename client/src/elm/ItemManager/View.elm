module ItemManager.View exposing
    ( viewItems
    , viewPageItem
    )

import Date exposing (Date)
import Gizra.Html exposing (emptyNode)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Item.Model exposing (ItemId, ItemsDict)
import ItemManager.Model exposing (..)
import ItemManager.Utils exposing (getItem, unwrapItemsDict)
import Pages.Item.View
import Pages.Items.View
import RemoteData exposing (RemoteData(..))
import Translate as Trans exposing (Language, translateText)
import User.Model exposing (User)
import Utils.WebData exposing (errorString, viewError)


{-| Show all Items page.
-}
viewItems : Date -> Language -> User -> Model -> Html Msg
viewItems currentDate language user model =
    let
        items =
            unwrapItemsDict model.items
    in
    Html.map MsgPagesItems <| Pages.Items.View.view currentDate language user items model.itemsPage


{-| Show the Item page.
-}
viewPageItem : Date -> Language -> ItemId -> User -> Model -> Html Msg
viewPageItem currentDate language id user model =
    case getItem id model of
        NotAsked ->
            -- This shouldn't happen, but if it does, we provide
            -- a button to load the editor
            div
                [ class "ui button"
                , onClick <| Subscribe id
                ]
                [ translateText language <| Trans.Item Trans.ReloadItem ]

        Loading ->
            emptyNode

        Failure error ->
            div []
                [ text <| errorString language error
                , div
                    [ class "ui button"
                    , onClick <| Subscribe id
                    ]
                    [ translateText language <| Trans.Item Trans.ReloadItem ]
                ]

        Success item ->
            div []
                [ Html.map (MsgPagesItem id) <| Pages.Item.View.view currentDate language user id item ]
