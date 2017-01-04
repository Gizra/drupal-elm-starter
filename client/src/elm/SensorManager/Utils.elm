module ItemManager.Utils
    exposing
        ( getItem
        , wrapHedleyDict
        , unwrapHedleyDict
        )

import Dict exposing (Dict)
import Item.Model exposing (Item, ItemId, HedleyDict)
import ItemManager.Model as ItemManager
import RemoteData exposing (RemoteData(..), WebData)


getItem : ItemId -> ItemManager.Model -> WebData Item
getItem id model =
    Dict.get id model.hedley
        |> Maybe.withDefault NotAsked


wrapHedleyDict : HedleyDict -> Dict ItemId (WebData Item)
wrapHedleyDict =
    Dict.map (\_ item -> Success item)


unwrapHedleyDict : Dict ItemId (WebData Item) -> HedleyDict
unwrapHedleyDict wrappedHedleyDict =
    wrappedHedleyDict
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
