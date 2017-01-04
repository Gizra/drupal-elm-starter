module Pusher.Model exposing (..)

import Item.Model exposing (Item, ItemId)


type alias PusherEvent =
    { itemId : ItemId
    , data : PusherEventData
    }


type PusherEventData
    = ItemUpdate Item
