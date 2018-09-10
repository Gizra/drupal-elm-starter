port module App.Update exposing (init, subscriptions, update)

import App.Model exposing (..)
import App.PageType exposing (Page(..))
import App.Utils exposing (handleErrors)
import Config
import Date
import Dict
import ItemManager.Model
import ItemManager.Update
import Json.Decode exposing (bool, decodeValue)
import Json.Encode exposing (Value)
import Pages.Login.Update
import Pusher.Model
import Pusher.Update
import RemoteData exposing (RemoteData(..), WebData)
import Task
import Time exposing (minute)
import User.Model exposing (..)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( config, cmds, activePage ) =
            case Dict.get flags.hostname Config.configs of
                Just config ->
                    let
                        defaultCmds =
                            [ Task.perform SetCurrentDate Date.now
                            ]

                        ( cmds, activePage_ ) =
                            if String.isEmpty flags.accessToken then
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
        , user = NotAsked
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
        HandleOfflineEvent (Ok offline) ->
            { model | offline = offline } ! []

        HandleOfflineEvent (Err err) ->
            model ! []

        Logout ->
            let
                ( modelUpdated, pusherLogoutCmd ) =
                    update (MsgPusher Pusher.Model.Logout) model
            in
            ( { emptyModel
                | accessToken = ""
                , activePage = Login
                , config = model.config
                , pusher = modelUpdated.pusher
              }
            , Cmd.batch
                [ accessTokenPort ""
                , pusherLogoutCmd
                ]
            )

        MsgItemManager subMsg ->
            case model.user of
                Success user ->
                    let
                        ( val, cmds, redirectPage, maybeError ) =
                            ItemManager.Update.update model.currentDate backendUrl model.accessToken user subMsg model.pageItem

                        modelUpdated =
                            { model | pageItem = val }

                        ( modelUpdatedWithSetPage, setPageCmds ) =
                            Maybe.map
                                (\page ->
                                    update (SetActivePage page) modelUpdated
                                )
                                redirectPage
                                |> Maybe.withDefault ( modelUpdated, Cmd.none )

                        modelUpdatedWithError =
                            handleErrors maybeError modelUpdatedWithSetPage
                    in
                    ( modelUpdatedWithError
                    , Cmd.batch
                        [ Cmd.map MsgItemManager cmds
                        , setPageCmds
                        ]
                    )

                _ ->
                    -- If we don't have a user, we have nothing to do.
                    model ! []

        MsgPusher subMsg ->
            let
                ( val, cmd ) =
                    Pusher.Update.update backendUrl subMsg model.pusher
            in
            ( { model | pusher = val }
            , Cmd.map MsgPusher cmd
            )

        NoOp ->
            model ! []

        PageLogin msg ->
            let
                ( val, cmds, ( webDataUser, accessToken ), maybeError ) =
                    Pages.Login.Update.update backendUrl msg model.pageLogin

                ( pusherModelUpdated, pusherLoginCmd ) =
                    pusherLogin model webDataUser accessToken

                modelUpdated =
                    { model
                        | pageLogin = val
                        , accessToken = accessToken
                        , pusher = pusherModelUpdated
                        , user = webDataUser
                    }

                ( modelUpdatedWithSetPage, setPageCmds ) =
                    case webDataUser of
                        -- If user was successfuly fetched, reditect to my
                        -- account page.
                        Success _ ->
                            let
                                nextPage =
                                    case modelUpdated.activePage of
                                        Login ->
                                            -- Redirect to the dashboard.
                                            Dashboard

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

                modelUpdatedWithError =
                    handleErrors maybeError modelUpdatedWithSetPage
            in
            ( modelUpdatedWithError
            , Cmd.batch
                [ Cmd.map PageLogin cmds
                , accessTokenPort accessToken
                , setPageCmds
                , pusherLoginCmd
                ]
            )

        SetActivePage page ->
            let
                activePage =
                    setActivePageAccess model.user page

                ( modelUpdated, command ) =
                    -- For a few, we also delegate some initialization
                    case activePage of
                        Dashboard ->
                            -- If we're showing a `Items` page, make sure we `Subscribe`
                            update (MsgItemManager ItemManager.Model.FetchAll) model

                        Item id ->
                            -- If we're showing a `Item`, make sure we `Subscribe`
                            update (MsgItemManager (ItemManager.Model.Subscribe id)) model

                        _ ->
                            ( model, Cmd.none )
            in
            -- Close the sidebar in case it was opened.
            ( { modelUpdated
                | activePage = setActivePageAccess model.user activePage
                , sidebarOpen = False
              }
            , command
            )

        SetCurrentDate date ->
            { model | currentDate = date } ! []

        Tick _ ->
            model ! [ Task.perform SetCurrentDate Date.now ]

        ToggleSideBar ->
            { model | sidebarOpen = not model.sidebarOpen } ! []


{-| Determine is a page can be accessed by a user (anonymous or authenticated),
and if not return a access denied page.

If the user is authenticated, don't allow them to revisit Login page. Do the
opposite for anonymous user - don't allow them to visit the MyAccount page.

-}
setActivePageAccess : WebData User -> Page -> Page
setActivePageAccess user page =
    case user of
        Success _ ->
            if page == Login then
                AccessDenied

            else
                page

        Failure _ ->
            if page == Login then
                page

            else if page == PageNotFound then
                page

            else
                AccessDenied

        _ ->
            page


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MsgItemManager <| ItemManager.Update.subscriptions model.pageItem model.activePage
        , Time.every minute Tick
        , offline (decodeValue bool >> HandleOfflineEvent)
        , Sub.map MsgPusher <| Pusher.Update.subscription
        ]


{-| Send access token to JS.
-}
port accessTokenPort : String -> Cmd msg


{-| Get a singal if internet connection is lost.
-}
port offline : (Value -> msg) -> Sub msg


{-| Login to pusher.
Either subscribes to the private channel, or to the general channel, according
to user.pusherChannel.
-}
pusherLogin : Model -> WebData User -> String -> ( Pusher.Model.Model, Cmd Msg )
pusherLogin model webDataUser accessToken =
    let
        -- Create the pusher login Msg, wrapped as a MsgPusher.
        pusherLoginMsg pusherKey pusherChannel =
            MsgPusher <|
                Pusher.Model.Login
                    pusherKey
                    pusherChannel
                    (Pusher.Model.AccessToken accessToken)

        -- Create a MsgPusher for login, or NoOp in case the user or the config
        -- are missing.
        msg =
            RemoteData.toMaybe webDataUser
                |> Maybe.map
                    (\user ->
                        RemoteData.toMaybe model.config
                            |> Maybe.map (\config -> pusherLoginMsg config.pusherKey user.pusherChannel)
                            |> Maybe.withDefault NoOp
                    )
                |> Maybe.withDefault NoOp

        ( updatedModel, pusherLoginCmd ) =
            update msg model
    in
    -- Return the pusher part of the model, as the pusher login action
    -- shouldn't change other parts.
    ( updatedModel.pusher, pusherLoginCmd )
