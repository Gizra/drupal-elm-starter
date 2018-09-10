module Fixtures exposing (exampleConfig, exampleModel, exampleUser)

{-| Some convenience functions to be used in unit tests.
-}

import App.Model as App exposing (Model, emptyModel)
import App.PageType exposing (Page(Dashboard))
import Config.Model as Config exposing (Model)
import Pusher.Model exposing (Cluster(UsEast1), PusherAppKey)
import RemoteData exposing (RemoteData(Success))
import User.Model exposing (User)


exampleModel : App.Model
exampleModel =
    { emptyModel
        | config = Success exampleConfig
        , user = Success exampleUser
        , activePage = Dashboard
    }


exampleConfig : Config.Model
exampleConfig =
    { backendUrl = "https://example.com"
    , debug = False
    , name = "local"
    , pusherKey = PusherAppKey "" UsEast1
    }


exampleUser : User
exampleUser =
    { id = 100
    , name = "Foo"
    , avatarUrl = "https://example.com"
    , pusherChannel = "general"
    }
