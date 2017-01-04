module Pages.Hedley.View exposing (view)

import App.PageType exposing (Page(..))
import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, onWithOptions)
import Pages.Hedley.Model exposing (Model, Msg(..))
import Item.Model exposing (Item, ItemId, HedleyDict)
import Table exposing (..)
import User.Model exposing (User)


view : Date -> User -> HedleyDict -> Model -> Html Msg
view currentDate currentUser hedley model =
    let
        lowerQuery =
            String.toLower model.query

        acceptableHedley =
            Dict.filter
                (\itemId item ->
                    (String.contains lowerQuery << String.toLower << .name) item
                )
                hedley
                |> Dict.toList

        searchResult =
            if List.isEmpty acceptableHedley then
                div [ class "ui segment" ] [ text "No hedley found" ]
            else
                Table.view config model.tableState acceptableHedley
    in
        div []
            [ h1 [] [ text "Hedley" ]
            , div [ class "ui input" ]
                [ input
                    [ placeholder "Search by Name"
                    , onInput SetQuery
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
                            [ a [ href "#", onClick <| SetRedirectPage <| PageItem itemId ]
                                [ text item.name ]
                            ]
                , sorter = Table.increasingOrDecreasingBy <| Tuple.second >> .name
                }
            ]
        , customizations = { defaultCustomizations | tableAttrs = [ class "ui celled table" ] }
        }
