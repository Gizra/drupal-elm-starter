port module SensorManager.Update exposing (update, subscriptions)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (Value)
import HttpBuilder exposing (get, withQueryParams)
import Pages.Sensor.Model
import Pages.Sensor.Update
import Pages.Sensors.Update
import Sensor.Model exposing (Sensor, SensorId)
import SensorManager.Decoder exposing (decodeSensorFromResponse, decodeSensorsFromResponse)
import SensorManager.Model exposing (..)
import SensorManager.Utils exposing (..)
import Pusher.Decoder exposing (decodePusherEvent)
import RemoteData exposing (RemoteData(..))
import User.Model exposing (User)
import Utils.WebData exposing (sendWithHandler)


update : Date -> BackendUrl -> String -> User -> Msg -> Model -> ( Model, Cmd Msg, Maybe Page )
update currentDate backendUrl accessToken user msg model =
    case msg of
        Subscribe id ->
            -- Note that we're waiting to get the response from the server
            -- before we subscribe to the Pusher events.
            case getSensor id model of
                NotAsked ->
                    let
                        ( updatedModel, updatedCmds ) =
                            fetchSensorFromBackend backendUrl accessToken id model
                    in
                        ( updatedModel
                        , updatedCmds
                        , Nothing
                        )

                Loading ->
                    ( model, Cmd.none, Nothing )

                Failure _ ->
                    let
                        ( val, cmds ) =
                            fetchSensorFromBackend backendUrl accessToken id model
                    in
                        ( val
                        , cmds
                        , Nothing
                        )

                Success _ ->
                    ( model, Cmd.none, Nothing )

        Unsubscribe id ->
            ( { model | sensors = Dict.remove id model.sensors }
            , Cmd.none
            , Nothing
            )

        FetchAll ->
            let
                ( val, cmds ) =
                    fetchAllSensorsFromBackend backendUrl accessToken model
            in
                ( val, cmds, Nothing )

        MsgPagesSensor id subMsg ->
            case getSensor id model of
                Success sensor ->
                    let
                        ( subModel, subCmd, redirectPage ) =
                            Pages.Sensor.Update.update backendUrl accessToken user subMsg sensor
                    in
                        ( { model | sensors = Dict.insert id (Success subModel) model.sensors }
                        , Cmd.map (MsgPagesSensor id) subCmd
                        , redirectPage
                        )

                _ ->
                    -- We've received a message for a Sensor which we either
                    -- aren't subscribed to, or dont' have initial data for yet.
                    -- This normally wouldn't happen, though we may needd to think
                    -- about synchronization between obtaining our initial data and
                    -- possible "pusher" messages. (Could pusher messages sometimes
                    -- arrive before the initial data, and if so, should we ignore
                    -- them or queue them up? We may need server timestamps on the initial
                    -- data and the pusher messages to know.)
                    ( model, Cmd.none, Nothing )

        MsgPagesSensors subMsg ->
            let
                ( subModel, subCmd, redirectPage ) =
                    Pages.Sensors.Update.update backendUrl accessToken user subMsg (unwrapSensorsDict model.sensors) model.sensorsPage
            in
                ( { model | sensorsPage = subModel }
                , Cmd.map MsgPagesSensors subCmd
                , redirectPage
                )

        HandleFetchedSensors (Ok sensors) ->
            ( { model | sensors = wrapSensorsDict sensors }
            , Cmd.none
            , Nothing
            )

        HandleFetchedSensors (Err err) ->
            ( model, Cmd.none, Nothing )

        HandleFetchedSensor sensorId (Ok sensor) ->
            let
                -- Let Sensor settings fetch own data.
                -- @todo: Pass the activePage here, so we can fetch
                -- data only when really needed.
                updatedModel =
                    { model | sensors = Dict.insert sensorId (Success sensor) model.sensors }
            in
                ( updatedModel
                , Cmd.none
                , Nothing
                )

        HandleFetchedSensor sensorId (Err err) ->
            ( { model | sensors = Dict.insert sensorId (Failure err) model.sensors }
            , Cmd.none
            , Nothing
            )

        HandlePusherEvent result ->
            case result of
                Ok event ->
                    let
                        subMsg =
                            Pages.Sensor.Model.HandlePusherEventData event.data
                    in
                        update currentDate backendUrl accessToken user (MsgPagesSensor event.sensorId subMsg) model

                Err err ->
                    let
                        _ =
                            Debug.log "Pusher decode Err" err
                    in
                        -- We'll log the error decoding the pusher event
                        ( model, Cmd.none, Nothing )


{-| A single port for all messages coming in from pusher for a `Sensor` ... they
will flow in once `subscribeSensor` is called. We'll wrap the structures on
the Javascript side so that we can dispatch them from here.
-}
port pusherSensorMessages : (Value -> msg) -> Sub msg


fetchSensorFromBackend : BackendUrl -> String -> SensorId -> Model -> ( Model, Cmd Msg )
fetchSensorFromBackend backendUrl accessToken sensorId model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/sensors/" ++ sensorId)
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeSensorFromResponse (HandleFetchedSensor sensorId)
    in
        ( { model | sensors = Dict.insert sensorId Loading model.sensors }
        , command
        )


fetchAllSensorsFromBackend : BackendUrl -> String -> Model -> ( Model, Cmd Msg )
fetchAllSensorsFromBackend backendUrl accessToken model =
    let
        command =
            HttpBuilder.get (backendUrl ++ "/api/sensors")
                |> withQueryParams [ ( "access_token", accessToken ) ]
                |> sendWithHandler decodeSensorsFromResponse HandleFetchedSensors
    in
        -- @todo: Move WebData to wrap dict?
        ( model
        , command
        )


subscriptions : Model -> Page -> Sub Msg
subscriptions model activePage =
    pusherSensorMessages (decodeValue decodePusherEvent >> HandlePusherEvent)
