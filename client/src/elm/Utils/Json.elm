module Utils.Json
    exposing
        ( decodeDate
        , decodeEmptyArrayAsEmptyDict
        , decodeError
        , decodeFloat
        , decodeInt
        , decodeListAsDict
        , decodeListAsDictByProperty
        )

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode exposing (Decoder, andThen, dict, fail, field, float, int, list, map, map2, nullable, oneOf, string, succeed, value)
import Json.Decode.Extra exposing (date)
import String


decodeDate : Decoder Date
decodeDate =
    string
        |> andThen (\val -> date)


decodeEmptyArrayAsEmptyDict : Decoder (Dict.Dict k v)
decodeEmptyArrayAsEmptyDict =
    list value
        |> andThen
            (\list ->
                let
                    length =
                        List.length list
                in
                    if length == 0 then
                        succeed Dict.empty
                    else
                        fail <| "Expected an empty array, not an array with length: " ++ toString length
            )


decodeError : Decoder String
decodeError =
    field "title" string


decodeFloat : Decoder Float
decodeFloat =
    oneOf
        [ float
        , string
            |> andThen
                (\val ->
                    case String.toFloat val of
                        Ok int ->
                            succeed int

                        Err _ ->
                            fail "Cannot convert string to float"
                )
        ]


{-| Cast String to Int.
-}
decodeInt : Decoder Int
decodeInt =
    oneOf
        [ int
        , string
            |> andThen
                (\val ->
                    case String.toInt val of
                        Ok int ->
                            succeed int

                        Err _ ->
                            fail "Cannot convert string to integer"
                )
        ]


decodeListAsDict : Decoder a -> Decoder (Dict String a)
decodeListAsDict decoder =
    decodeListAsDictByProperty "id" decodeInt decoder toString


decodeListAsDictByProperty : String -> Decoder a -> Decoder v -> (a -> comparable) -> Decoder (Dict String v)
decodeListAsDictByProperty property keyDecoder valDecoder stringFunc =
    list (map2 (,) (field property keyDecoder) valDecoder)
        |> andThen
            (\valList ->
                List.map (\( id, value ) -> ( stringFunc id, value )) valList
                    |> Dict.fromList
                    |> succeed
            )
