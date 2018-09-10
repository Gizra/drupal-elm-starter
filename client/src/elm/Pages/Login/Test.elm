module Pages.Login.Test exposing (all)

import Dict
import Expect
import Http
import Pages.Login.Model exposing (Msg(HandleFetchedAccessToken, HandleFetchedUser), emptyModel)
import Pages.Login.Update exposing (update)
import RemoteData exposing (RemoteData(Failure, NotAsked))
import Test exposing (Test, describe, test)


{-| Fetch authorization Tests.
-}
fetchFromBackendTests : Test
fetchFromBackendTests =
    Test.describe "Fetch from Backend tests"
        [ fetchUnauthorized
        ]


fetchUnauthorized : Test
fetchUnauthorized =
    let
        url =
            "http://localhost/unio/server/www"

        badRequest =
            Http.BadStatus
                { body = """
                {
                    "type":"http:\\/\\/www.w3.org\\/Protocols\\/rfc2616\\/rfc2616-sec10.html#sec10.4.2",
                    "title":"Bad credentials",
                    "status":401,
                    "detail":"Unauthorized."
                }
                """
                , status = { code = 401, message = "Authorization Required" }
                , headers = Dict.fromList [ ( "Cache-Control", "no-cache, must-revalidate" ), ( "Content-Type", "application/problem+json; charset=utf-8" ), ( "Expires", "Sun, 19 Nov 1978 05:00:00 GMT" ) ]
                , url = "http://localhost/server/www/api/me?access_token=some-wrong-token"
                }

        ( updatedModel, cmds, ( webdata, accessToken ), _ ) =
            update url (HandleFetchedAccessToken (Err badRequest)) emptyModel
    in
    describe "Unauthorized tests"
        [ test "Receiving Unauthorized should result in error and no user" <|
            \() -> Expect.equal (Failure badRequest) webdata
        , test "Receiving Unauthorized should clear accesstoken" <|
            \() -> Expect.equal "" accessToken
        ]


{-| Fetch User Data Tests.
-}
fetchUserUnauthorized : Test
fetchUserUnauthorized =
    let
        url =
            "http://localhost/unio/server/www"

        badRequest =
            Http.BadStatus
                { body = """
                {
                    "type":"http:\\/\\/www.w3.org\\/Protocols\\/rfc2616\\/rfc2616-sec10.html#sec10.4.2",
                    "title":"Bad credentials",
                    "status":401,
                    "detail":"Unauthorized."
                }
                """
                , status = { code = 401, message = "Authorization Required" }
                , headers = Dict.fromList [ ( "Cache-Control", "no-cache, must-revalidate" ), ( "Content-Type", "application/problem+json; charset=utf-8" ), ( "Expires", "Sun, 19 Nov 1978 05:00:00 GMT" ) ]
                , url = "http://localhost/server/www/api/me?access_token=some-wrong-token"
                }

        invalidToken =
            "some-wrong-token"

        ( updatedModel, cmds, ( webdata, accessToken ), _ ) =
            update url (HandleFetchedUser invalidToken (Err badRequest)) emptyModel
    in
    describe "Invalid Token tests"
        [ test "Receiving Unauthorized should result in no error and no user" <|
            \() -> Expect.equal NotAsked webdata
        , test "Receiving Unauthorized should clear accesstoken" <|
            \() -> Expect.equal "" accessToken
        ]


fetchUserFromBackendTests : Test
fetchUserFromBackendTests =
    describe "Fetch User from Backend tests"
        [ fetchUserUnauthorized
        ]


all : Test
all =
    describe "Login tests"
        [ fetchFromBackendTests
        , fetchUserFromBackendTests
        ]
