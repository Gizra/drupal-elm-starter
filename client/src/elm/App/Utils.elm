module App.Utils exposing (handleErrors)

import App.Model exposing (Model, Msg(..))
import Error.Model exposing (Error)
import Error.Utils exposing (debugLog)
import Maybe.Extra exposing (unwrap)


{-| If there was an error, add it to the top of the list,
and send to console.
-}
handleErrors : Maybe Error -> Model -> Model
handleErrors maybeError model =
    let
        errors =
            unwrap model.errors
                (\error ->
                    let
                        _ =
                            debugLog error
                    in
                    error :: model.errors
                )
                maybeError
    in
    { model | errors = errors }
