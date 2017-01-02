module Sensor.Decoder
    exposing
        ( decodeSensor
        , decodeSensorsDict
        )

import Json.Decode exposing (Decoder, andThen, dict, fail, field, int, list, map, map2, nullable, string, succeed)
import Json.Decode.Pipeline exposing (custom, decode, optional, required)
import Sensor.Model exposing (..)
import Utils.Json exposing (decodeListAsDict)


decodeSensor : Decoder Sensor
decodeSensor =
    decode Sensor
        |> required "label" string
        |> optional "image" string "http://placehold.it/350x150"


decodeSensorsDict : Decoder SensorsDict
decodeSensorsDict =
    decodeListAsDict decodeSensor
