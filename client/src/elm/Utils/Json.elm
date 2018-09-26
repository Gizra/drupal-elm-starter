module Utils.Json exposing
    ( decodeDate
    , decodeEmptyArrayAsEmptyDict
    , decodeError
    , decodeListAsDict
    , decodeListAsDictByProperty
    )

import Date exposing (Date)
import Dict exposing (Dict)
import Gizra.Json exposing (decodeEmptyArrayAs, decodeInt)
import Json.Decode exposing (Decoder, andThen, dict, fail, field, float, int, list, map, map2, nullable, oneOf, string, succeed, value)
import Json.Decode.Extra exposing (date)


decodeDate : Decoder Date
decodeDate =
    string
        |> andThen (\val -> date)


decodeEmptyArrayAsEmptyDict : Decoder (Dict.Dict k v)
decodeEmptyArrayAsEmptyDict =
    decodeEmptyArrayAs Dict.empty


decodeError : Decoder String
decodeError =
    field "title" string


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
