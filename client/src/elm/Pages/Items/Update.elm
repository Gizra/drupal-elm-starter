module Pages.Items.Update exposing (update)

import App.PageType exposing (Page(..))
import Pages.Items.Model exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Page )
update msg model =
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
