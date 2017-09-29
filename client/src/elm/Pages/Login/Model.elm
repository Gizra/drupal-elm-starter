module Pages.Login.Model
    exposing
        ( AccessToken
        , emptyModel
        , Model
        , Msg(HandleFetchedAccessToken, HandleFetchedUser, SetName, SetPassword, TryLogin)
        )

import Http
import User.Model exposing (User)


type alias AccessToken =
    String


type alias LoginForm =
    { name : String
    , pass : String
    }


type alias Model =
    LoginForm


type Msg
    = HandleFetchedAccessToken (Result Http.Error AccessToken)
    | HandleFetchedUser AccessToken (Result Http.Error User)
    | SetName String
    | SetPassword String
    | TryLogin


emptyModel : Model
emptyModel =
    LoginForm "admin" "admin"
