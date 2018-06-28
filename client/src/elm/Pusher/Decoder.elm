module Pusher.Decoder exposing (decodePusherEvent)

import Item.Decoder exposing (decodeItem)
import Item.Model exposing (Item)
import Json.Decode as Json exposing (Decoder, andThen, at, fail, field, map, map2, string)
import Json.Decode.Pipeline exposing (custom, decode, optional, required, requiredAt)
import Pusher.Model exposing (..)


decodePusherEvent : Decoder PusherEvent
decodePusherEvent =
    decode PusherEvent
        |> requiredAt [ "data", "id" ] string
        |> custom decodePusherEventData


decodePusherEventData : Decoder PusherEventData
decodePusherEventData =
    field "eventType" string
        |> andThen
            (\type_ ->
                case type_ of
                    "item__update" ->
                        map ItemUpdate decodeItemUpdateData

                    _ ->
                        fail (type_ ++ " is not a recognized 'type' for PusherEventData.")
            )


decodeItemUpdateData : Decoder Item
decodeItemUpdateData =
    field "data" decodeItem
