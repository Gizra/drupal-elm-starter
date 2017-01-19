module Pusher.Model exposing (..)

import Item.Model exposing (Item, ItemId)


type Cluster
    = ApSouthEast1
    | EuWest1
    | UsEast1


type alias PusherAppKey =
    { key : String
    , cluster : Cluster
    }


type alias PusherEvent =
    { itemId : ItemId
    , data : PusherEventData
    }


type PusherEventData
    = ItemUpdate Item


{-| Return the event names that should be added via JS.
-}
eventNames : List String
eventNames =
    [ "item__update" ]
