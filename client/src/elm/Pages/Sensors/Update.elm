module Pages.Sensors.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import User.Model exposing (..)
import Pages.Sensors.Model exposing (Model, Msg(..))
import Sensor.Model exposing (SensorsDict)


update : BackendUrl -> String -> User -> Msg -> SensorsDict -> Model -> ( Model, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg sensors model =
    case msg of
        SetRedirectPage page ->
            ( model, Cmd.none, Just page )

        SetQuery newQuery ->
            ( { model | query = newQuery }
            , Cmd.none
            , Nothing
            )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            , Nothing
            )
