module Pages.Login.Update exposing
    ( fetchUserFromBackend
    , update
    )

import Config.Model exposing (BackendUrl)
import Error.Model exposing (Error)
import Error.Utils exposing (httpError, noError)
import Http exposing (Error(BadStatus))
import HttpBuilder exposing (..)
import Pages.Login.Decoder exposing (..)
import Pages.Login.Model as Login exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import User.Decoder exposing (decodeUser)
import User.Model exposing (..)
import Utils.WebData exposing (sendWithHandler)


update : BackendUrl -> Msg -> Model -> ( Model, Cmd Msg, ( WebData User, AccessToken ), Maybe Error.Model.Error )
update backendUrl msg model =
    case msg of
        HandleFetchedAccessToken (Ok accessToken) ->
            ( model
            , fetchUserFromBackend backendUrl accessToken
            , ( Loading, accessToken )
            , noError
            )

        HandleFetchedAccessToken (Err error) ->
            ( model
            , Cmd.none
            , ( Failure error, "" )
            , httpError "Pages.Login.Update" "HandleFetchedAccessToken" error
            )

        HandleFetchedUser accessToken (Ok user) ->
            ( model
            , Cmd.none
            , ( Success user, accessToken )
            , noError
            )

        HandleFetchedUser accessToken (Err error) ->
            let
                -- If Access token in local storage is invalid, make sure we don't show a "bad credentials" error.
                ( webdata, errorType ) =
                    case error of
                        BadStatus e ->
                            ( NotAsked, noError )

                        _ ->
                            ( Failure error
                            , httpError "Pages.Login.Update" "HandleFetchedUser" error
                            )
            in
            ( model
            , Cmd.none
            , ( webdata, "" )
            , errorType
            )

        SetName name ->
            let
                loginForm =
                    model.loginForm

                loginForm_ =
                    { loginForm | name = name }
            in
            ( { model | loginForm = loginForm_ }
            , Cmd.none
            , ( NotAsked, "" )
            , noError
            )

        SetPassword pass ->
            let
                loginForm =
                    model.loginForm

                loginForm_ =
                    { loginForm | pass = pass }
            in
            ( { model | loginForm = loginForm_ }
            , Cmd.none
            , ( NotAsked, "" )
            , noError
            )

        TryLogin ->
            ( model
            , fetchAccessTokenFromBackend backendUrl model.loginForm
            , ( Loading, "" )
            , noError
            )


{-| Get access token from backend.
-}
fetchAccessTokenFromBackend : BackendUrl -> LoginForm -> Cmd Msg
fetchAccessTokenFromBackend backendUrl loginForm =
    let
        credentials =
            encodeCredentials ( loginForm.name, loginForm.pass )
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
