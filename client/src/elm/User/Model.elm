module User.Model exposing (User, UserId)


type alias UserId =
    String


type alias User =
    { id : Int
    , name : String
    , avatarUrl : String
    , pusherChannel : String
    }
