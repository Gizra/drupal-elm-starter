module Pages.Login.View exposing (view)

import Gizra.Html exposing (emptyNode)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Pages.Login.Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Translate as Trans exposing (Language, translateString, translateText)
import User.Model exposing (..)
import Utils.WebData exposing (errorString, viewError)


view : Language -> WebData User -> Model -> Html Msg
view language user model =
    div [ class "ui container login" ]
        [ div
            [ class "ui segment" ]
            [ i [ class "huge grey dashboard brand icon" ] []
            , viewForm language user model
            ]
        ]


viewForm : Language -> WebData User -> Model -> Html Msg
viewForm language user model =
    let
        spinner =
            i [ class "notched circle loading icon" ] []

        ( isLoading, isError ) =
            case user of
                Loading ->
                    ( True, False )

                Failure _ ->
                    ( False, True )

                _ ->
                    ( False, False )

        error =
            case user of
                Failure error ->
                    div [ class "ui error message" ] [ text <| errorString language error ]

                _ ->
                    emptyNode
    in
    div []
        [ Html.form
            [ onSubmit TryLogin
            , action "javascript:void(0);"
            , class "ui form login-form"
            ]
            [ div [ class "field" ]
                [ input
                    [ type_ "text"
                    , name "username"
                    , placeholder <| translateString language <| Trans.Login Trans.EnterYourUsername
                    , onInput SetName
                    , value model.loginForm.name
                    ]
                    []
                ]
            , div [ class "field" ]
                [ input
                    [ type_ "password"
                    , placeholder <| translateString language <| Trans.Login Trans.EnterYourPassword
                    , name "password"
                    , onInput SetPassword
                    , value model.loginForm.pass
                    ]
                    []
                ]

            -- Submit button
            , button
                [ disabled isLoading
                , class "ui large fluid primary button"
                ]
                [ span [ hidden <| not isLoading ] [ spinner ]
                , span [ hidden isLoading ] [ translateText language <| Trans.Login Trans.LoginVerb ]
                ]
            ]
        , error
        ]
