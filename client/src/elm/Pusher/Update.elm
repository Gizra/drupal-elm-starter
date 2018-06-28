port module Pusher.Update exposing (subscription, update)

import Config.Model exposing (BackendUrl)
import Pusher.Model exposing (..)
import Pusher.Utils exposing (getClusterName)


{-| Login to pusher.
-}
port pusherLogin : PusherConfig -> Cmd msg


{-| Logout from pusher.
-}
port pusherLogout : () -> Cmd msg


{-| Receive pusher errors.
-}
port pusherError : (PusherError -> msg) -> Sub msg


{-| Receive pusher state changes.
-}
port pusherState : (String -> msg) -> Sub msg


{-| Subscription to connection status.
-}
subscription : Sub Msg
subscription =
    Sub.batch
        [ pusherError HandleError
        , pusherState HandleStateChange
        ]


update : BackendUrl -> Msg -> Model -> ( Model, Cmd Msg )
update backendUrl msg model =
    case msg of
        HandleError error ->
            ( { model | errors = error :: model.errors }
            , Cmd.none
            )

        HandleStateChange state ->
            let
                connectionStatus =
                    case state of
                        "intialized" ->
                            Initialized

                        "connecting" ->
                            Connecting Nothing

                        "connected" ->
                            Connected

                        "unavailable" ->
                            Unavailable Nothing

                        "failed" ->
                            Failed

                        "disconnected" ->
                            Disconnected

                        _ ->
                            Other state
            in
            ( { model | connectionStatus = connectionStatus }
            , Cmd.none
            )

        Login pusherAppKey pusherChannel (AccessToken accessToken) ->
            let
                pusherConfig =
                    { key = pusherAppKey.key
                    , cluster = getClusterName pusherAppKey.cluster
                    , authEndpoint = backendUrl ++ "/api/pusher_auth?access_token=" ++ accessToken
                    , channel = pusherChannel
                    , eventNames = Pusher.Model.eventNames
                    }
            in
            ( model
            , pusherLogin pusherConfig
            )

        Logout ->
            ( model, pusherLogout () )
