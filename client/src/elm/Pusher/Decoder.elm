module Pusher.Decoder exposing (decodePusherEvent)

import Json.Decode exposing (Decoder, andThen, fail, field, map, string)
import Json.Decode.Pipeline exposing (custom, decode, requiredAt)
import Pusher.Model exposing (PusherEvent, PusherEventData(ItemUpdate))
import Item.Decoder exposing (decodeItem)
import Item.Model exposing (Item)


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
