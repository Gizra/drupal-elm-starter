module Pusher.Model exposing (..)

import Item.Model exposing (Item, ItemId)


type alias Model =
    { connectionStatus : ConnectionStatus
    , errors : List PusherError
    , showErrorModal : Bool
    }


emptyModel : Model
emptyModel =
    { connectionStatus = Initialized
    , errors = []
    , showErrorModal = False
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


type alias PusherConfig =
    { key : String
    , cluster : String
    , authEndpoint : String
    , channel : String
    , eventNames : List String
    }


{-| Represents the state of our pusher connection.
This mostly tracks <https://pusher.com/docs/client_api_guide/client_connect#available-states>
The `(Maybe Int)` parameters track when the next reconnection attempt will take
place, if that is known.
We'll start in `Initialized` state, and stay there until we get a `Login`
message. At that point, we'll gradually proceed through `Connecting` to
`Connected` (if all goes well).
-}
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
    | HandleConnectingIn Int
    | ShowErrorModal
    | HideErrorModal
    | Login PusherAppKey AccessToken
    | Logout
