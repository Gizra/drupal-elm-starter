module Item.Encoder exposing (encodeItemName)

import Json.Encode exposing (Value, object, string)
import Item.Model exposing (Item)


{-| Encode just the name of the item, so we can send a
PATCH request to update the name on the backend.
-}
encodeItemName : Item -> Value
encodeItemName item =
    object [ ( "label", string item.name ) ]
