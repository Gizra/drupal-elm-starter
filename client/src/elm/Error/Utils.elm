module Error.Utils exposing
    ( debugLog
    , httpError
    , noError
    , plainError
    )

import Error.Model exposing (Error, ErrorType(..))
import Http
import Translate exposing (Language(English))
import Utils.WebData exposing (viewError)


{-| Log an error to the console.
-}
debugLog : Error -> String
debugLog error =
    let
        message =
            case error.error of
                Http err ->
                    -- Debug.log can always be in English.
                    Utils.WebData.errorString English err

                Plain txt ->
                    txt

        id =
            error.module_ ++ "." ++ error.location
    in
    Debug.log id message



{- Helper functions for returning a `Maybe Error` from an update function. -}


noError : Maybe Error
noError =
    Nothing


httpError : String -> String -> Http.Error -> Maybe Error
httpError module_ location error =
    Just <| Error module_ location (Http error)


plainError : String -> String -> String -> Maybe Error
plainError module_ location error =
    Just <| Error module_ location (Plain error)
