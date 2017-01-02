module SensorManager.Utils
    exposing
        ( getSensor
        , wrapSensorsDict
        , unwrapSensorsDict
        )

import Dict exposing (Dict)
import Sensor.Model exposing (Sensor, SensorId, SensorsDict)
import SensorManager.Model as SensorManager
import RemoteData exposing (RemoteData(..), WebData)


getSensor : SensorId -> SensorManager.Model -> WebData Sensor
getSensor id model =
    Dict.get id model.sensors
        |> Maybe.withDefault NotAsked


wrapSensorsDict : SensorsDict -> Dict SensorId (WebData Sensor)
wrapSensorsDict =
    Dict.map (\_ sensor -> Success sensor)


unwrapSensorsDict : Dict SensorId (WebData Sensor) -> SensorsDict
unwrapSensorsDict wrappedSensorsDict =
    wrappedSensorsDict
        |> Dict.foldl
            (\sensorId wrappedSensor accum ->
                case wrappedSensor of
                    Success sensor ->
                        ( sensorId, sensor ) :: accum

                    _ ->
                        accum
            )
            []
        |> Dict.fromList
