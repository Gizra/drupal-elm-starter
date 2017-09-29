module ItemManager.View
    exposing
        ( viewPageItem
        , viewItems
        )

import Pages.Item.View
import Html exposing (div, Html, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Pages.Items.View
import Item.Model exposing (ItemId)
import ItemManager.Model exposing (Model, Msg(MsgPagesItem, MsgPagesItems, Subscribe))
import ItemManager.Utils exposing (getItem, unwrapItemsDict)
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success))
import Utils.Html exposing (emptyNode)
import Utils.WebData exposing (viewError)


{-| Show all Items page.
-}
viewItems : Model -> Html Msg
viewItems model =
    let
        items =
            unwrapItemsDict model.items
    in
        Html.map MsgPagesItems <| Pages.Items.View.view items model.itemsPage


{-| Show the Item page.
-}
viewPageItem : ItemId -> Model -> Html Msg
viewPageItem id model =
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
            emptyNode

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
                [ Html.map (MsgPagesItem id) <| Pages.Item.View.view item ]
