module Pages.Login.Update exposing (fetchUserFromBackend, update)

import Config.Model exposing (BackendUrl)
import Http exposing (Error(BadStatus))
import HttpBuilder exposing (withHeader, withQueryParams)
import User.Model exposing (User)
import Pages.Login.Model exposing (AccessToken, Model, Msg(HandleFetchedAccessToken, HandleFetchedUser, SetName, SetPassword, TryLogin))
import Pages.Login.Decoder exposing (decodeAccessToken, encodeCredentials)
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success), WebData)
import User.Decoder exposing (decodeUser)
import Utils.WebData exposing (sendWithHandler)


update : BackendUrl -> Msg -> Model -> ( Model, Cmd Msg, ( WebData User, AccessToken ) )
update backendUrl msg model =
    case msg of
        HandleFetchedAccessToken (Ok accessToken) ->
            ( model
            , fetchUserFromBackend backendUrl accessToken
            , ( Loading, accessToken )
            )

        HandleFetchedAccessToken (Err err) ->
            ( model
            , Cmd.none
            , ( Failure err, "" )
            )

        HandleFetchedUser accessToken (Ok user) ->
            ( model
            , Cmd.none
            , ( Success user, accessToken )
            )

        HandleFetchedUser _ (Err err) ->
            let
                -- If Access token in local storage is invalid, make sure we don't show a "bad credentials" error.
                webdata =
                    case err of
                        BadStatus _ ->
                            NotAsked

                        _ ->
                            Failure err
            in
                ( model
                , Cmd.none
                , ( webdata, "" )
                )

        SetName name ->
            ( { model | name = name }
            , Cmd.none
            , ( NotAsked, "" )
            )

        SetPassword pass ->
            ( { model | pass = pass }
            , Cmd.none
            , ( NotAsked, "" )
            )

        TryLogin ->
            ( model
            , fetchAccessTokenFromBackend backendUrl model
            , ( Loading, "" )
            )


{-| Get access token from backend.
-}
fetchAccessTokenFromBackend : BackendUrl -> Model -> Cmd Msg
fetchAccessTokenFromBackend backendUrl model =
    let
        credentials =
            encodeCredentials ( model.name, model.pass )
    in
        HttpBuilder.get (backendUrl ++ "/api/login-token")
            |> withHeader "Authorization" ("Basic " ++ credentials)
            |> sendWithHandler decodeAccessToken HandleFetchedAccessToken


{-| Get user data from backend.
-}
fetchUserFromBackend : BackendUrl -> String -> Cmd Msg
fetchUserFromBackend backendUrl accessToken =
    HttpBuilder.get (backendUrl ++ "/api/me")
        |> withQueryParams [ ( "access_token", accessToken ) ]
        |> sendWithHandler decodeUser (HandleFetchedUser accessToken)
