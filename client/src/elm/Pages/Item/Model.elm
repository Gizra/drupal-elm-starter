module Pages.Item.Model exposing (..)

import App.PageType exposing (Page(..))
import Item.Model exposing (Item)
import Pusher.Model exposing (PusherEventData)


type Msg
    = HandlePusherEventData PusherEventData
    | SetRedirectPage Page
    | EditingNameBegin
    | EditingNameUpdate String
    | EditingNameFinish
    | EditingNameCancel


{-| This lets us keep track of who has updated the item that
we're returning from `Pages.Item.Update.update` to the
ItemManager. If the user changed it, then we should send the
updated item to the server; if, on the other hand, we got
this change from the server in the first place, all we have to
do is make a note of it ourselves.
-}
type ItemUpdate
    = UpdateFromBackend Item
    | UpdateFromUser Item
    | NoUpdate


{-| This allows you to easily do something with the updated
item if there is one, wherever you got it from. Cf.
`Maybe.Extra.unwrap`.
-}
unwrapItemUpdate : a -> (Item -> a) -> ItemUpdate -> a
unwrapItemUpdate default f itemUpdate =
    case itemUpdate of
        UpdateFromBackend item ->
            f item

        UpdateFromUser item ->
            f item

        NoUpdate ->
            default


{-| At the moment the only state peculiar to the Item page is
whether the user is currently editing the name of the item,
and if so, what have they typed in. (We wouldn't have to keep
track of the latter in the Model, but doing so allows us to
the contents of the input field if the users navigates to
another page and then comes back.)
-}
type alias Model =
    { editingItemName : Maybe String }


emptyModel : Model
emptyModel =
    { editingItemName = Nothing }
