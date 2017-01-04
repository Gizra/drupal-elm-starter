module App.PageType exposing (Page(..))

{-| Prevent circula dependency.
-}


type alias ItemId =
    String


type Page
    = AccessDenied
    | Dashboard
    | Item ItemId
    | Login
    | MyAccount
    | PageNotFound
