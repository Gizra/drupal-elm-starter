module ItemManager.Decoder
    exposing
        ( decodeItemFromResponse
        , decodeItemsFromResponse
        )

import Json.Decode exposing (at, Decoder)
import Item.Model exposing (Item, ItemsDict)
import Item.Decoder exposing (decodeItem, decodeItemsDict)


decodeItemFromResponse : Decoder Item
decodeItemFromResponse =
    at [ "data", "0" ] decodeItem


decodeItemsFromResponse : Decoder ItemsDict
decodeItemsFromResponse =
    at [ "data" ] decodeItemsDict
