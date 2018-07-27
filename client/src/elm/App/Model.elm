module App.Model
    exposing
        ( ConfiguredModel
        , Flags
        , Model
        , Msg(..)
        , MsgLoggedIn(..)
        , Sidebar(..)
        , emptyModel
        )

import App.PageType exposing (Page(..))
import Config.Model
import Date exposing (Date)
import Error.Model exposing (Error)
import ItemManager.Model exposing (Model, emptyModel)
import Pages.Login.Model exposing (Model, emptyModel)
import Pusher.Model
import RemoteData exposing (RemoteData(..), WebData)
import Restful.Login exposing (LoginStatus)
import Time exposing (Time)
import Translate exposing (Language(English))
import User.Model exposing (..)


{-| `credentials` represents the credentials we've cached from `Restful.Login,
if any.

`hostname` is our hostname.

-}
type alias Flags =
    { credentials : String
    , hostname : String
    }


{-| We're now doing our model in layers, corresponding to the logic
of the startup process.

The first thing we need is a configuration, but there are a few things that
make sense to have even without a configuration. So, they are here also.

We have the `activePage` here because it really models what the user **wants**
to be seeing, and we may need to remember that whether or not we're configured
yet.

`language` is here because we always need some kind of language, if just a
default.

Everything which depends upon a configuration is included in `ConfiguredModel`,
so we don't have those things at all until we have a `Configuration`.

-}
type alias Model =
    { activePage : Page
    , configured : RemoteData String ConfiguredModel
    , currentDate : Date
    , errors : List Error
    , language : Language
    , offline : Bool
    }


emptyModel : Model
emptyModel =
    { activePage = LoginPage
    , configured = NotAsked
    , currentDate = Date.fromTime 0
    , errors = []
    , language = English
    , offline = False
    }


{-| The parts of the model that depend upon configuration.
-}
type alias ConfiguredModel =
    { config : Config.Model.Model
    , login : LoginStatus User LoggedInModel
    , pageLogin : Pages.Login.Model.Model
    , pusher : Pusher.Model.Model
    , sidebarOpen : Bool
    }


{-| The parts of the model which depend on someone being logged in ...
that is, which are not available to anonymous users. This clarifies
client-side access controls, and facilitates things like throwing
away user-specific data when someone logs out (since we've collected
all the user-specific data here).
-}
type alias LoggedInModel =
    { pageItem : ItemManager.Model.Model
    }


{-| Our messages. We don't have separate messages for things requiring
configuration, because:

  - Configuration should resolve itself before we receive any messages.

  - If configuration fails, there is nothing we can do to recover.

However, we do have a separate `MsgLoggedIn` type for messages we can only
handle when someone is logged in. This makes it easy to write the code in our
`update` function that gets the needed credentials and supplies them (or
complains if no one is logged in).

-}
type Msg
    = HandleOfflineEvent (Result String Bool)
    | MsgLogin (Restful.Login.Msg User)
    | MsgPageLogin Pages.Login.Model.Msg
    | MsgPusher Pusher.Model.Msg
    | NoOp
    | SetActivePage Page
    | SetCurrentDate Date
    | Tick Time
    | ToggleSideBar


{-| These are messages which we can only handle if we're
logged in.
-}
type MsgLoggedIn
    = MsgItemManager ItemManager.Model.Msg


type Sidebar
    = Top
    | Left
