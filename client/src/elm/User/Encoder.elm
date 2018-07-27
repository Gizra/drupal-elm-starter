module User.Encoder exposing (encodeUser)

import Json.Encode exposing (Value, int, object, string)
import User.Model exposing (..)


encodeUser : User -> Value
encodeUser user =
    object
        [ ( "id", int user.id )
        , ( "label", string user.name )
        , ( "avatar_url", string user.avatarUrl )
        , ( "pusher_channel", string user.pusherChannel )
        ]
