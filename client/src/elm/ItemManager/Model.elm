module ItemManager.Model exposing (Model, Msg(..), emptyModel)

import Dict exposing (Dict)
import Http
import Item.Model exposing (Item, ItemId, ItemsDict)
import Pages.Item.Model
import Pages.Items.Model
import Pusher.Model exposing (PusherEvent)
import RemoteData exposing (RemoteData(..), WebData)


{-| We track any Items we are currently subscribed to.

In theory, we'll only typically have one at a time. However, the logic of
subscribing and unsubscribing will be required in any event. Thus, it's
simpler to just track whatever we're subscribed to. That is, we could limit
ourselves to one subscription at a time, but that would actually be extra
logic, not less.

Each `Pages.Item.Model.Model` is wrapped in a `WebData`, because we
derive it from fetching a `Item` through `WebData` ... it's simplest to
just stay within the `WebData` container.

-}
type alias Model =
    { items : Dict ItemId (WebData Item)
    , itemsPage : Pages.Items.Model.Model
    }


{-| Our messages:

  - `Subscribe` means "fetch the Item and listen to its pusher events"

  - `Unsubscribe` means "forget the Item and stop listening to its pusher events"

  - `MsgPagesItem` is a message to route to a Item viewer

-}
type Msg
    = Subscribe ItemId
    | Unsubscribe ItemId
    | FetchAll
    | MsgPagesItem ItemId Pages.Item.Model.Msg
    | MsgPagesItems Pages.Items.Model.Msg
    | HandleFetchedItem ItemId (Result Http.Error Item)
    | HandleFetchedItems (Result Http.Error ItemsDict)
    | HandlePusherEvent (Result String PusherEvent)


emptyModel : Model
emptyModel =
    { items = Dict.empty
    , itemsPage = Pages.Items.Model.emptyModel
    }
