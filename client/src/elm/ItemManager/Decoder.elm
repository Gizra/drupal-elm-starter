module ItemManager.Decoder exposing
    ( decodeItemFromResponse
    , decodeItemsFromResponse
    )

import Item.Decoder exposing (decodeItem, decodeItemsDict)
import Item.Model exposing (Item, ItemsDict)
import Json.Decode exposing (Decoder, at)


decodeItemFromResponse : Decoder Item
decodeItemFromResponse =
    at [ "data", "0" ] decodeItem


decodeItemsFromResponse : Decoder ItemsDict
decodeItemsFromResponse =
    at [ "data" ] decodeItemsDict
