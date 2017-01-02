module Pages.Dashboard.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Sensor.Model exposing (Sensor, SensorId)
import User.Model exposing (User)


view : User -> SensorsDict -> Html Msg
view currentUser sensors =
    div []
        [ h1 [ class "ui header" ] [ text "Dashboard" ]
        , div [ class "ui divider" ] []
        , viewActiveIncidents sensors
        ]


viewActiveIncidents : SensorsDict -> Html Msg
viewActiveIncidents sensors =
    let
        orderedIncidentes =
            getOrderedIncidents sensors
    in
        -- @todo: Filter out
        if (List.isEmpty orderedIncidentes) then
            div [ style [ ( "font-size", "300%" ) ] ]
                [ i [ class "ui icon check circle teal huge" ] []
                , text "No active incidents!"
                ]
        else
            div [ class "ui cards" ]
                (List.map
                    (\{ sensorId, sensor, incidentId, incident } ->
                        Html.map (MsgIncident sensorId incidentId) (Incident.View.view ( sensorId, sensor ) ( incidentId, incident ) IncidentViewFull)
                    )
                    orderedIncidentes
                )
