module ItemManager.Utils exposing
    ( getItem
    , unwrapItemsDict
    , wrapItemsDict
    )

import Dict exposing (Dict)
import Item.Model exposing (Item, ItemId, ItemsDict)
import ItemManager.Model as ItemManager
import RemoteData exposing (RemoteData(..), WebData)


getItem : ItemId -> ItemManager.Model -> WebData Item
getItem id model =
    Dict.get id model.items
        |> Maybe.withDefault NotAsked


wrapItemsDict : ItemsDict -> Dict ItemId (WebData Item)
wrapItemsDict =
    Dict.map (\_ item -> Success item)


unwrapItemsDict : Dict ItemId (WebData Item) -> ItemsDict
unwrapItemsDict wrappedItemsDict =
    wrappedItemsDict
        |> Dict.foldl
            (\itemId wrappedItem accum ->
                case wrappedItem of
                    Success item ->
                        ( itemId, item ) :: accum

                    _ ->
                        accum
            )
            []
        |> Dict.fromList
