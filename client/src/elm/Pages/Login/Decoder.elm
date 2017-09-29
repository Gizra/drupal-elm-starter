module Pages.Login.Decoder exposing (decodeAccessToken, encodeCredentials)

import Base64
import Json.Decode as Decode
import Pages.Login.Model exposing (AccessToken)


decodeAccessToken : Decode.Decoder AccessToken
decodeAccessToken =
    Decode.at [ "access_token" ] <| Decode.string


encodeCredentials : ( String, String ) -> String
encodeCredentials ( name, pass ) =
    let
        base64 =
            Base64.encode (name ++ ":" ++ pass)
    in
        case base64 of
            Ok result ->
                result

            Err _ ->
                ""
