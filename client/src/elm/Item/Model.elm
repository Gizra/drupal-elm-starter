module Item.Model exposing
    ( Item
    , ItemId
    , ItemsDict
    )

import Dict exposing (Dict)


type alias ItemId =
    String


type alias Item =
    { name : String
    , image : String
    , privateNote : Maybe String
    }


type alias ItemsDict =
    Dict ItemId Item
