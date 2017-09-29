module Pages.Items.View exposing (view)

import App.PageType
import Dict
import Html exposing (a, div, Html, h2, input, text)
import Html.Attributes exposing (class, placeholder, style)
import Html.Attributes.Aria exposing (ariaLabel)
import Html.Events exposing (onClick, onInput)
import Pages.Items.Model exposing (Model, Msg(SetQuery, SetRedirectPage, SetTableState))
import Item.Model exposing (Item, ItemId, ItemsDict)
import Table exposing (defaultCustomizations)
import Utils.Html exposing (emptyNode)


view : ItemsDict -> Model -> Html Msg
view items model =
    let
        lowerQuery =
            String.toLower model.query

        acceptableItems =
            Dict.filter
                (\_ item ->
                    (String.contains lowerQuery << String.toLower << .name) item
                )
                items
                |> Dict.toList

        searchResult =
            if List.isEmpty acceptableItems then
                if Dict.isEmpty items then
                    -- No items are present, so it means we are fethcing
                    -- them.
                    emptyNode
                else
                    div [ class "ui segment" ] [ text "No items found" ]
            else
                Table.view config model.tableState acceptableItems
    in
        div []
            [ div
                [ class "ui secondary pointing fluid menu" ]
                [ h2
                    [ class "ui header" ]
                    [ text "Items" ]
                , div
                    [ class "right menu" ]
                    [ a
                        [ class "ui active item" ]
                        [ text "Overview" ]
                    ]
                ]
            , div [ class "ui input" ]
                [ input
                    [ placeholder "Search by Name"
                    , onInput SetQuery
                    , ariaLabel "Search by Name"
                    ]
                    []
                ]
            , searchResult
            ]


config : Table.Config ( ItemId, Item ) Msg
config =
    Table.customConfig
        { toId = \( itemId, _ ) -> itemId
        , toMsg = SetTableState
        , columns =
            [ Table.veryCustomColumn
                { name = "Name"
                , viewData =
                    \( itemId, item ) ->
                        Table.HtmlDetails []
                            [ a
                                [ onClick <| SetRedirectPage <| App.PageType.Item itemId
                                , style [ ( "cursor", "pointer" ) ]
                                ]
                                [ text item.name ]
                            ]
                , sorter = Table.increasingOrDecreasingBy <| Tuple.second >> .name
                }
            ]
        , customizations = { defaultCustomizations | tableAttrs = [ class "ui celled table" ] }
        }
