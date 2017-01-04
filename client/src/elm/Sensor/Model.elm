module Item.Model
    exposing
        ( Item
        , ItemId
        , HedleyDict
        )

import Dict exposing (Dict)


type alias ItemId =
    String


type alias Item =
    { name : String
    , image : String
    }


type alias HedleyDict =
    Dict ItemId Item
