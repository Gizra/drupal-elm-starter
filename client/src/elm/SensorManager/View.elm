module SensorManager.View
    exposing
        ( viewPageSensor
        , viewSensors
        )

import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Pages.Sensor.View
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Pages.Sensors.View
import Sensor.Model exposing (SensorId, SensorsDict)
import SensorManager.Model exposing (..)
import SensorManager.Utils exposing (getSensor, unwrapSensorsDict)
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (viewError)


{-| Show all Sensors page.
-}
viewSensors : Date -> User -> Model -> Html Msg
viewSensors currentDate user model =
    let
        sensors =
            unwrapSensorsDict model.sensors
    in
        div []
            [ Html.map MsgPagesSensors <| Pages.Sensors.View.view currentDate user sensors model.sensorsPage
            ]


{-| Show the Sensor page.
-}
viewPageSensor : Date -> SensorId -> User -> Model -> Html Msg
viewPageSensor currentDate id user model =
    case getSensor id model of
        NotAsked ->
            -- This shouldn't happen, but if it does, we provide
            -- a button to load the editor
            div
                [ class "ui button"
                , onClick <| Subscribe id
                ]
                [ text "Re-load Sensor" ]

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

        Success sensor ->
            div []
                [ Html.map (MsgPagesSensor id) <| Pages.Sensor.View.view currentDate user id sensor ]
