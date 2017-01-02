module App.PageType exposing (Page(..))

{-| Prevent circula dependency.
-}


type alias SensorId =
    String


type Page
    = AccessDenied
    | Login
    | MyAccount
    | PageNotFound
    | PageSensor SensorId
    | Sensors
