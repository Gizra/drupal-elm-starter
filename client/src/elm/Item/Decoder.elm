module Item.Decoder exposing (decodeItem, decodeItemsDict)

import Json.Decode exposing (Decoder, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, optionalAt, required)
import Item.Model exposing (Item, ItemsDict)
import Utils.Json exposing (decodeListAsDict)


decodeItem : Decoder Item
decodeItem =
    decode Item
        |> required "label" string
        |> optionalAt [ "image", "styles", "large" ] string "http://placehold.it/350x150"
        |> optional "private_note" (nullable string) Nothing


decodeItemsDict : Decoder ItemsDict
decodeItemsDict =
    decodeListAsDict decodeItem
