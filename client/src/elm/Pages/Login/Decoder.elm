module Pages.Login.Decoder exposing (..)

import Base64 exposing (encode)
import Json.Decode as Decode
import Pages.Login.Model exposing (AccessToken)


decodeAccessToken : Decode.Decoder AccessToken
decodeAccessToken =
    Decode.at [ "access_token" ] <| Decode.string


decodeError : Decode.Decoder String
decodeError =
    Decode.at [ "data", "error" ] <| Decode.string


encodeCredentials : ( String, String ) -> String
encodeCredentials ( name, pass ) =
    Base64.encode (name ++ ":" ++ pass)
