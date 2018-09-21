module Error.View exposing (view, viewError)

import Error.Model exposing (Error, ErrorType(..))
import Gizra.Html exposing (emptyNode)
import Html exposing (..)
import Html.Attributes exposing (..)
import Translate as Trans exposing (Language)
import Utils.WebData exposing (viewError)


view : Language -> List Error -> Html msg
view language errors =
    if List.isEmpty errors then
        emptyNode

    else
        div [ class "debug-errors" ]
            [ h2 [] [ text "Debug Errors" ]
            , ul [] (List.map (viewError language) errors)
            ]


viewError : Language -> Error -> Html msg
viewError language error =
    let
        prefix =
            text <| error.module_ ++ "." ++ error.location ++ ": "
    in
    case error.error of
        Http err ->
            li []
                [ prefix
                , Utils.WebData.viewError language err
                ]

        Plain txt ->
            li []
                [ prefix
                , text txt
                ]
