module Pages.Items.Update exposing (update)

import App.PageType exposing (Page(..))
import Config.Model exposing (BackendUrl)
import User.Model exposing (..)
import Pages.Items.Model exposing (Model, Msg(..))
import Item.Model exposing (ItemsDict)


update : BackendUrl -> String -> User -> Msg -> ItemsDict -> Model -> ( Model, Cmd Msg, Maybe Page )
update backendUrl accessToken user msg items model =
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
