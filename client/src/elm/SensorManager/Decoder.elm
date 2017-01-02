module SensorManager.Decoder
    exposing
        ( decodeSensorFromResponse
        , decodeSensorsFromResponse
        )

import Json.Decode exposing (at, Decoder)
import Sensor.Model exposing (Sensor, SensorsDict)
import Sensor.Decoder exposing (decodeSensor, decodeSensorsDict)


decodeSensorFromResponse : Decoder Sensor
decodeSensorFromResponse =
    at [ "data", "0" ] decodeSensor


decodeSensorsFromResponse : Decoder SensorsDict
decodeSensorsFromResponse =
    at [ "data" ] decodeSensorsDict
