module User.Model exposing (..)


type alias UserId =
    String


type alias User =
    { id : Int
    , name : String
    , avatarUrl : String
    }
