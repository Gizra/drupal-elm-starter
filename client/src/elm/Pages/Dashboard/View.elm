module Pages.Dashboard.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Item.Model exposing (Item, ItemId)
import User.Model exposing (User)


view : User -> ItemsDict -> Html Msg
view currentUser items =
    div []
        [ h1 [ class "ui header" ] [ text "Dashboard" ]
        , div [ class "ui divider" ] []
        , viewActiveIncidents items
        ]


viewActiveIncidents : ItemsDict -> Html Msg
viewActiveIncidents items =
    let
        orderedIncidentes =
            getOrderedIncidents items
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
                    (\{ itemId, item, incidentId, incident } ->
                        Html.map (MsgIncident itemId incidentId) (Incident.View.view ( itemId, item ) ( incidentId, incident ) IncidentViewFull)
                    )
                    orderedIncidentes
                )
