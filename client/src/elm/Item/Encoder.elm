module Item.Encoder exposing (encodeItemTitlePatch)

import Json.Encode exposing (Value, object, string)
import Item.Model exposing (Item)


encodeItemTitlePatch : Item -> Value
encodeItemTitlePatch item =
    object [ ( "label", string item.name ) ]
