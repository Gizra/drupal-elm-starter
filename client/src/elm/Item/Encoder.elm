module Item.Encoder exposing (encodeItemTitle)

import Json.Encode exposing (Value, object, string)
import Item.Model exposing (Item)


encodeItemTitle : Item -> Value
encodeItemTitle item =
    object [ ( "label", string item.name ) ]
