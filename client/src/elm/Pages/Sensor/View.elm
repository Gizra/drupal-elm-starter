module Pages.Sensor.View exposing (view)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Sensor.Model exposing (Msg(..))
import Sensor.Model exposing (SensorId, Sensor)
import User.Model exposing (User)


view : Date -> User -> SensorId -> Sensor -> Html Msg
view currentDate currentUser sensorId sensor =
    div []
        [ div
            [ class "ui secondary pointing fluid menu" ]
            [ h1
                [ class "ui header" ]
                [ text sensor.name ]
            ]
        , div
            [ class "ui divider" ]
            []
        ]
