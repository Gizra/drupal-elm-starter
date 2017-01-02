module Pages.Sensors.Model exposing (..)

import App.PageType exposing (Page(..))
import Table


type alias Model =
    { tableState : Table.State
    , query : String
    }


type Msg
    = SetRedirectPage Page
    | SetTableState Table.State
    | SetQuery String


emptyModel : Model
emptyModel =
    { tableState = Table.initialSort "Name"
    , query = ""
    }
