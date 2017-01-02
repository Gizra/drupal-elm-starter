module Pages.Sensor.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import User.Model exposing (..)
import Pages.Sensor.Model exposing (Msg(..))
import Pusher.Model exposing (PusherEventData(..))
import Sensor.Model exposing (Sensor)


update : BackendUrl -> String -> User -> Msg -> Sensor -> ( Sensor, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg sensor =
    case msg of
        HandlePusherEventData event ->
            case event of
                SensorCreate newSensor ->
                    -- So, the idea is that we have a new or updated sensor,
                    -- which has already been saved at the server. Note that
                    -- we may have just pushed this change ourselves, so it's
                    -- already reflected here.
                    ( newSensor.sensor
                    , Cmd.none
                    , Nothing
                    )

        SetRedirectPage page ->
            ( sensor, Cmd.none, Just page )
