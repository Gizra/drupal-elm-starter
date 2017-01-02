module Pusher.Decoder exposing (decodePusherEvent)

import Json.Decode as Json exposing (Decoder, andThen, at, fail, field, map, map2, string)
import Json.Decode.Pipeline exposing (custom, decode, optional, required, requiredAt)
import Pusher.Model exposing (..)
import Sensor.Decoder exposing (decodeSensor)


decodePusherEvent : Decoder PusherEvent
decodePusherEvent =
    decode PusherEvent
        |> requiredAt [ "data", "sensor" ] string
        |> custom decodePusherEventData


decodePusherEventData : Decoder PusherEventData
decodePusherEventData =
    field "eventType" string
        |> andThen
            (\type_ ->
                case type_ of
                    "sensor__update" ->
                        map SensorUpdate decodeSensorUpdateData

                    _ ->
                        fail (type_ ++ " is not a recognized 'type' for PusherEventData.")
            )


decodeSensorUpdateData : Decoder SensorUpdateData
decodeSensorUpdateData =
    decode SensorUpdateData
        |> requiredAt [ "data", "0" ] decodeSensor
