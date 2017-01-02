module Main exposing (..)

import App.Model exposing (Flags, Model, Msg)
import App.Update exposing (init, update, subscriptions)
import App.Router exposing (..)
import App.View exposing (view)
import RouteUrl


main : RouteUrl.RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init = App.Update.init
        , update = App.Update.update
        , view = App.View.view
        , subscriptions = App.Update.subscriptions
        }
