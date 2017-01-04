module ItemManager.Decoder
    exposing
        ( decodeItemFromResponse
        , decodeHedleyFromResponse
        )

import Json.Decode exposing (at, Decoder)
import Item.Model exposing (Item, HedleyDict)
import Item.Decoder exposing (decodeItem, decodeHedleyDict)


decodeItemFromResponse : Decoder Item
decodeItemFromResponse =
    at [ "data", "0" ] decodeItem


decodeHedleyFromResponse : Decoder HedleyDict
decodeHedleyFromResponse =
    at [ "data" ] decodeHedleyDict
