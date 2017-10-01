module Utils.WebData exposing (errorString, getError, sendWithHandler, whenSuccess, viewError)

import Html exposing (..)
import Http
import HttpBuilder exposing (..)
import Json.Decode exposing (Decoder)
import RemoteData exposing (..)
import Translate as Trans exposing (Language, translateString)


{-| Get Error message as `String`.
-}
errorString : Language -> Http.Error -> String
errorString language error =
    case error of
        Http.BadUrl message ->
            translateString language Trans.ErrorBadUrl

        Http.BadPayload message _ ->
            translateString language <| Trans.ErrorBadPayload message

        Http.NetworkError ->
            translateString language Trans.ErrorNetworkError

        Http.Timeout ->
            translateString language Trans.ErrorTimeout

        Http.BadStatus response ->
            translateString language <| Trans.ErrorBadStatus response.status.message


{-| Provide some `Html` to view an error message.
-}
viewError : Language -> Http.Error -> Html any
viewError language error =
    div [] [ text <| errorString language error ]


whenSuccess : RemoteData e a -> result -> (a -> result) -> result
whenSuccess remoteData default func =
    case remoteData of
        Success val ->
            func val

        _ ->
            default


sendWithHandler : Decoder a -> (Result Http.Error a -> msg) -> RequestBuilder a1 -> Cmd msg
sendWithHandler decoder tagger builder =
    builder
        |> withExpect (Http.expectJson decoder)
        |> send tagger


getError : RemoteData e a -> Maybe e
getError remoteData =
    case remoteData of
        Failure err ->
            Just err

        _ ->
            Nothing
