module Pusher.Model exposing (AccessToken(..), Cluster(..), ConnectionStatus(..), Model, Msg(..), PusherAppKey, PusherChannel, PusherConfig, PusherError, PusherEvent, PusherEventData(..), emptyModel, eventNames)

import Item.Model exposing (Item, ItemId)


type alias Model =
    { connectionStatus : ConnectionStatus
    , errors : List PusherError
    }


emptyModel : Model
emptyModel =
    { connectionStatus = Initialized
    , errors = []
    }


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


type AccessToken
    = AccessToken String


type alias PusherChannel =
    String


type alias PusherConfig =
    { key : String
    , cluster : String
    , authEndpoint : String
    , channel : String
    , eventNames : List String
    }


type ConnectionStatus
    = Initialized
    | Connecting (Maybe Int)
    | Connected
    | Unavailable (Maybe Int)
    | Failed
    | Disconnected
    | Other String


type alias PusherError =
    { code : Maybe Int
    , message : Maybe String
    }


{-| Return the event names that should be added via JS.
-}
eventNames : List String
eventNames =
    [ "item__update" ]


type Msg
    = HandleError PusherError
    | HandleStateChange String
    | Login PusherAppKey PusherChannel AccessToken
    | Logout
