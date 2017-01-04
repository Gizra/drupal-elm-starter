module App.PageType exposing (Page(..))

{-| Prevent circula dependency.
-}


type alias ItemId =
    String


type Page
    = AccessDenied
    | Login
    | MyAccount
    | PageNotFound
    | PageItem ItemId
    | Items
