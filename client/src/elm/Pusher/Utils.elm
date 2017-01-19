module Pusher.Utils exposing (getEventNameFromType)

import Pusher.Model exposing (PusherEventType)


getEventNameFromType : PusherEventType -> String
getEventNameFromType eventType =
    toString eventType
