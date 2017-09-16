module Pages.MyAccount.View exposing (view)

import Html exposing (div, text, img, Html)
import Html.Attributes exposing (class, src)
import RemoteData exposing (RemoteData(..), WebData)
import User.Model exposing (..)
import Utils.Html exposing (emptyNode)


-- VIEW


view : WebData User -> Html a
view user =
    let
        ( name, avatar ) =
            case user of
                Success val ->
                    ( val.name, img [ src val.avatarUrl ] [] )

                _ ->
                    ( "", emptyNode )
    in
        div [ class "ui centered card" ]
            [ div [ class "image" ] [ avatar ]
            , div [ class "content" ]
                [ div [ class "header" ] [ text <| "Welcome " ++ name ]
                ]
            ]
