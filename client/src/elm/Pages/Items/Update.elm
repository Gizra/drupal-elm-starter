module Pages.Items.Update exposing (update)

import App.PageType exposing (Page)
import Pages.Items.Model exposing (Model, Msg(SetQuery, SetRedirectPage, SetTableState))


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Page )
update msg model =
    case msg of
        SetQuery newQuery ->
            ( { model | query = newQuery }
            , Cmd.none
            , Nothing
            )

        SetRedirectPage page ->
            ( model, Cmd.none, Just page )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            , Nothing
            )
