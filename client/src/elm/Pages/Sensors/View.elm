module Pages.Sensors.View exposing (view)

import App.PageType exposing (Page(..))
import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, onWithOptions)
import Pages.Sensors.Model exposing (Model, Msg(..))
import Sensor.Model exposing (Sensor, SensorId, SensorsDict)
import Table exposing (..)
import User.Model exposing (User)


view : Date -> User -> SensorsDict -> Model -> Html Msg
view currentDate currentUser sensors model =
    let
        lowerQuery =
            String.toLower model.query

        acceptableSensors =
            Dict.filter
                (\sensorId sensor ->
                    (String.contains lowerQuery << String.toLower << .name) sensor
                )
                sensors
                |> Dict.toList

        searchResult =
            if List.isEmpty acceptableSensors then
                div [ class "ui segment" ] [ text "No sensors found" ]
            else
                Table.view config model.tableState acceptableSensors
    in
        div []
            [ h1 [] [ text "Sensors" ]
            , div [ class "ui input" ]
                [ input
                    [ placeholder "Search by Name"
                    , onInput SetQuery
                    ]
                    []
                ]
            , searchResult
            ]


config : Table.Config ( SensorId, Sensor ) Msg
config =
    Table.customConfig
        { toId = \( sensorId, _ ) -> sensorId
        , toMsg = SetTableState
        , columns =
            [ Table.veryCustomColumn
                { name = "Name"
                , viewData =
                    \( sensorId, sensor ) ->
                        Table.HtmlDetails []
                            [ a [ href "#", onClick <| SetRedirectPage <| PageSensor sensorId ]
                                [ text sensor.name ]
                            ]
                , sorter = Table.increasingOrDecreasingBy <| Tuple.second >> .name
                }
            ]
        , customizations = { defaultCustomizations | tableAttrs = [ class "ui celled table" ] }
        }
