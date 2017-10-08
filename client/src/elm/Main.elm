module Main exposing (main)

import App.Model exposing (Flags, Model, Msg)
import App.Update exposing (init, update, subscriptions)
import App.Router exposing (delta2url, location2messages)
import App.View exposing (view)
import RouteUrl


main : RouteUrl.RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
