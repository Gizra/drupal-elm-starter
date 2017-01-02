module SensorManager.Model exposing (..)

import Dict exposing (Dict)
import Http
import Pages.Sensor.Model
import Pages.Sensors.Model
import Pusher.Model exposing (PusherEvent)
import RemoteData exposing (RemoteData(..), WebData)
import Sensor.Model exposing (Sensor, SensorId, SensorsDict)


{-| We track any Sensors we are currently subscribed to.

In theory, we'll only typically have one at a time. However, the logic of
subscribing and unsubscribing will be required in any event. Thus, it's
simpler to just track whatever we're subscribed to. That is, we could limit
ourselves to one subscription at a time, but that would actually be extra
logic, not less.

Each `Pages.Sensor.Model.Model` is wrapped in a `WebData`, because we
derive it from fetching a `Sensor` through `WebData` ... it's simplest to
just stay within the `WebData` container.
-}
type alias Model =
    { sensors : Dict SensorId (WebData Sensor)
    , sensorsPage : Pages.Sensors.Model.Model
    }


{-| Our messages:

* `Subscribe` means "fetch the Sensor and listen to its pusher events"

* `Unsubscribe` means "forget the Sensor and stop listening to its pusher events"

* `MsgPagesSensor` is a message to route to a Sensor viewer
-}
type Msg
    = Subscribe SensorId
    | Unsubscribe SensorId
    | FetchAll
    | MsgPagesSensor SensorId Pages.Sensor.Model.Msg
    | MsgPagesSensors Pages.Sensors.Model.Msg
    | HandleFetchedSensor SensorId (Result Http.Error Sensor)
    | HandleFetchedSensors (Result Http.Error SensorsDict)
    | HandlePusherEvent (Result String PusherEvent)


emptyModel : Model
emptyModel =
    { sensors = Dict.empty
    , sensorsPage = Pages.Sensors.Model.emptyModel
    }
