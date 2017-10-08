module Pages.Login.View exposing (view)

import Html exposing (button, div, Html, i, input, span, text)
import Html.Attributes exposing (action, class, disabled, hidden, name, placeholder, type_, value)
import Html.Attributes.Aria exposing (ariaLabel)
import Html.Events exposing (onInput, onSubmit)
import Pages.Login.Model exposing (Model, Msg(SetName, SetPassword, TryLogin))
import RemoteData exposing (RemoteData(Failure, Loading), WebData)
import User.Model exposing (User)
import Utils.Html exposing (emptyNode)
import Utils.WebData exposing (viewError)


view : WebData User -> Model -> Html Msg
view user model =
    div [ class "ui container login" ]
        [ div
            [ class "ui segment" ]
            [ i [ class "huge grey dashboard brand icon" ] []
            , viewForm user model
            ]
        ]


viewForm : WebData User -> Model -> Html Msg
viewForm user model =
    let
        spinner =
            i [ class "notched circle loading icon" ] []

        ( isLoading, _ ) =
            case user of
                Loading ->
                    ( True, False )

                Failure _ ->
                    ( False, True )

                _ ->
                    ( False, False )

        error =
            case user of
                Failure err ->
                    div [ class "ui error message" ] [ viewError err ]

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
                        , placeholder "Username"
                        , onInput SetName
                        , value model.name
                        , ariaLabel "Enter your username"
                        ]
                        []
                    ]
                , div [ class "field" ]
                    [ input
                        [ type_ "password"
                        , placeholder "Password"
                        , name "password"
                        , onInput SetPassword
                        , value model.pass
                        , ariaLabel "Enter your password"
                        ]
                        []
                    ]

                -- Submit button
                , button
                    [ disabled isLoading
                    , class "ui large fluid primary button"
                    ]
                    [ span [ hidden <| not isLoading ] [ spinner ]
                    , span [ hidden isLoading ] [ text "Login" ]
                    ]
                ]
            , error
            ]
