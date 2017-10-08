module User.Model exposing (User)


type alias User =
    { id : Int
    , name : String
    , avatarUrl : String
    , pusherChannel : String
    }
