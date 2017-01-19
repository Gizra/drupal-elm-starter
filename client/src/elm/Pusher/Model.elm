module Pusher.Model exposing (..)

import Item.Model exposing (Item, ItemId)


type alias PusherEvent =
    { itemId : ItemId
    , data : PusherEventData
    }


type alias PusherConfig =
    { key : String
    , events : List String
    }


type PusherEventType
    = ItemUpdate


type PusherEventData
    = ItemUpdate Item


pusherEvents : List String
pusherEvents =
    [ "item__update"
    ]
