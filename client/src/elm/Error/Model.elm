module Error.Model exposing
    ( Error
    , ErrorType(..)
    )

import Http


{-| An error message contains the module and Msg or function
where the error arose, and the actual error data.
-}
type alias Error =
    { module_ : String
    , location : String
    , error : ErrorType
    }


{-| An error is either the outcome of an Http request or a
plain string (i.e. indicating a logical error).
-}
type ErrorType
    = Http Http.Error
    | Plain String
