module Sensor.Model
    exposing
        ( Sensor
        , SensorId
        , SensorsDict
        )

import Dict exposing (Dict)


type alias SensorId =
    String


type alias Sensor =
    { name : String
    , image : String
    }


type alias SensorsDict =
    Dict SensorId Sensor
