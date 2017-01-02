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
                    "sensor__create" ->
                        map SensorCreate decodeSensorCreateData

                    _ ->
                        fail (type_ ++ " is not a recognized 'type' for PusherEventData.")
            )


decodeSensorCreateData : Decoder SensorCreateData
decodeSensorCreateData =
    decode SensorCreateData
        |> requiredAt [ "data", "0" ] decodeSensor
