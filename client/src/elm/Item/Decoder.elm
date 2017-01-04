module Item.Decoder
    exposing
        ( decodeItem
        , decodeItemsDict
        )

import Json.Decode exposing (Decoder, andThen, dict, fail, field, int, list, map, map2, nullable, string, succeed)
import Json.Decode.Pipeline exposing (custom, decode, optional, required)
import Item.Model exposing (..)
import Utils.Json exposing (decodeListAsDict)


decodeItem : Decoder Item
decodeItem =
    decode Item
        |> required "label" string
        |> optional "image" string "http://placehold.it/350x150"


decodeItemsDict : Decoder ItemsDict
decodeItemsDict =
    decodeListAsDict decodeItem
