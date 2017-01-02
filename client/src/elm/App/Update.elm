port module App.Update exposing (init, update, subscriptions)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import Config
import Date
import Dict
import Pages.Login.Update
import SensorManager.Model
import SensorManager.Update
import RemoteData exposing (RemoteData(..), WebData)
import Task
import Time exposing (minute)
import User.Model exposing (..)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( config, cmds, activePage ) =
            case (Dict.get flags.hostname Config.configs) of
                Just config ->
                    let
                        defaultCmds =
                            [ pusherKey config.pusherKey
                            , Task.perform SetCurrentDate Date.now
                            ]

                        ( cmds, activePage_ ) =
                            if (String.isEmpty flags.accessToken) then
                                -- Check if we have already an access token.
                                ( defaultCmds, Login )
                            else
                                ( [ Cmd.map PageLogin <| Pages.Login.Update.fetchUserFromBackend config.backendUrl flags.accessToken ] ++ defaultCmds
                                , emptyModel.activePage
                                )
                    in
                        ( Success config
                        , cmds
                        , activePage_
                        )

                Nothing ->
                    ( Failure "No config found"
                    , [ Cmd.none ]
                    , emptyModel.activePage
                    )
    in
        ( { emptyModel
            | accessToken = flags.accessToken
            , activePage = activePage
            , config = config
          }
        , Cmd.batch cmds
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        backendUrl =
            case model.config of
                Success config ->
                    config.backendUrl

                _ ->
                    ""
    in
        case msg of
            Logout ->
                ( { emptyModel
                    | accessToken = ""
                    , activePage = Login
                    , config = model.config
                  }
                , accessTokenPort ""
                )

            MsgSensorManager subMsg ->
                case model.user of
                    Success user ->
                        let
                            ( val, cmds, redirectPage ) =
                                SensorManager.Update.update model.currentDate backendUrl model.accessToken user subMsg model.pageSensor

                            modelUpdated =
                                { model | pageSensor = val }

                            ( modelUpdatedWithSetPage, setPageCmds ) =
                                Maybe.map
                                    (\page ->
                                        update (SetActivePage page) modelUpdated
                                    )
                                    redirectPage
                                    |> Maybe.withDefault ( modelUpdated, Cmd.none )
                        in
                            ( modelUpdatedWithSetPage
                            , Cmd.batch
                                [ Cmd.map MsgSensorManager cmds
                                , setPageCmds
                                ]
                            )

                    _ ->
                        -- If we don't have a user, we have nothing to do.
                        model ! []

            PageLogin msg ->
                let
                    ( val, cmds, ( webDataUser, accessToken ) ) =
                        Pages.Login.Update.update backendUrl msg model.pageLogin

                    modelUpdated =
                        { model
                            | pageLogin = val
                            , accessToken = accessToken
                            , user = webDataUser
                        }

                    ( modelWithRedirect, setActivePageCmds ) =
                        case webDataUser of
                            -- If user was successfuly fetched, reditect to my
                            -- account page.
                            Success _ ->
                                let
                                    nextPage =
                                        case modelUpdated.activePage of
                                            Login ->
                                                -- Redirect to the dashboard.
                                                Sensors

                                            _ ->
                                                -- Keep the active page.
                                                modelUpdated.activePage
                                in
                                    update (SetActivePage nextPage) modelUpdated

                            Failure _ ->
                                -- Unset the wrong access token.
                                update (SetActivePage Login) { modelUpdated | accessToken = "" }

                            _ ->
                                modelUpdated ! []
                in
                    ( modelWithRedirect
                    , Cmd.batch
                        [ Cmd.map PageLogin cmds
                        , accessTokenPort accessToken
                        , setActivePageCmds
                        ]
                    )

            SetActivePage page ->
                let
                    activePage =
                        setActivePageAccess model.user page

                    ( modelUpdated, command ) =
                        -- For a few, we also delegate some initialization
                        case activePage of
                            Sensors ->
                                -- If we're showing a `Sensors` page, make sure we `Subscribe`
                                update (MsgSensorManager SensorManager.Model.FetchAll) model

                            PageSensor id ->
                                -- If we're showing a `Sensor`, make sure we `Subscribe`
                                update (MsgSensorManager (SensorManager.Model.Subscribe id)) model

                            _ ->
                                ( model, Cmd.none )
                in
                    ( { modelUpdated | activePage = setActivePageAccess model.user activePage }
                    , command
                    )

            SetCurrentDate date ->
                { model | currentDate = date } ! []

            Tick _ ->
                model ! [ Task.perform SetCurrentDate Date.now ]


{-| Determine is a page can be accessed by a user (anonymous or authenticated),
and if not return a access denied page.

If the user is authenticated, don't allow them to revisit Login page. Do the
opposite for anonumous user - don't allow them to visit the MyAccount page.
-}
setActivePageAccess : WebData User -> Page -> Page
setActivePageAccess user page =
    case user of
        Success _ ->
            if page == Login then
                AccessDenied
            else
                page

        _ ->
            if page == MyAccount then
                AccessDenied
            else
                page


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MsgSensorManager <| SensorManager.Update.subscriptions model.pageSensor model.activePage
        , Time.every minute Tick
        ]


{-| Send access token to JS.
-}
port accessTokenPort : String -> Cmd msg


{-| Send Pusher key to JS.
-}
port pusherKey : String -> Cmd msg
