module ItemManager.View
    exposing
        ( viewPageItem
        , viewHedley
        )

import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Pages.Item.View
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Pages.Hedley.View
import Item.Model exposing (ItemId, HedleyDict)
import ItemManager.Model exposing (..)
import ItemManager.Utils exposing (getItem, unwrapHedleyDict)
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (viewError)


{-| Show all Hedley page.
-}
viewHedley : Date -> User -> Model -> Html Msg
viewHedley currentDate user model =
    let
        hedley =
            unwrapHedleyDict model.hedley
    in
        div []
            [ Html.map MsgPagesHedley <| Pages.Hedley.View.view currentDate user hedley model.hedleyPage
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
