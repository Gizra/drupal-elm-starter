module Pages.Hedley.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import User.Model exposing (..)
import Pages.Hedley.Model exposing (Model, Msg(..))
import Item.Model exposing (HedleyDict)


update : BackendUrl -> String -> User -> Msg -> HedleyDict -> Model -> ( Model, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg hedley model =
    case msg of
        SetRedirectPage page ->
            ( model, Cmd.none, Just page )

        SetQuery newQuery ->
            ( { model | query = newQuery }
            , Cmd.none
            , Nothing
            )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            , Nothing
            )
