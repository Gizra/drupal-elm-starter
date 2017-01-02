module Utils.WebData exposing (sendWithHandler, viewError)

import Json.Decode exposing (Decoder)
import Html exposing (..)
import Http
import HttpBuilder exposing (..)


{-| Provide some `Html` to view an error message.
-}
viewError : Http.Error -> Html any
viewError error =
    case error of
        Http.BadUrl message ->
            div [] [ text "URL is not valid." ]

        Http.BadPayload message _ ->
            div []
                [ p [] [ text "The server responded with data of an unexpected type." ]
                , p [] [ text message ]
                ]

        Http.NetworkError ->
            div [] [ text "There was a network error." ]

        Http.Timeout ->
            div [] [ text "The network request timed out." ]

        Http.BadStatus response ->
            div []
                [ div [] [ text "The server indicated the following error:" ]
                , div [] [ text response.status.message ]
                ]


sendWithHandler : Decoder a -> (Result Http.Error a -> msg) -> RequestBuilder a1 -> Cmd msg
sendWithHandler decoder tagger builder =
    builder
        |> withExpect (Http.expectJson decoder)
        |> send tagger
