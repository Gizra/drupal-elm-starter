module Pusher.Model exposing (..)

import Item.Model exposing (Item, ItemId)


type alias PusherEvent =
    { itemId : ItemId
    , data : PusherEventData
    }


type alias PusherConfig =
    { key : String
    , events : List PusherEventType
    }


type alias PusherEventType =
    String


type PusherEventData
    = ItemUpdate Item


pusherEvents : List PusherEventType
pusherEvents =
    [ "item__update"
    ]
