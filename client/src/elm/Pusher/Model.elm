module Pusher.Model exposing (..)

import Sensor.Model exposing (Sensor, SensorId)


type alias PusherEvent =
    { sensorId : SensorId
    , data : PusherEventData
    }


type PusherEventData
    = SensorUpdate Sensor
