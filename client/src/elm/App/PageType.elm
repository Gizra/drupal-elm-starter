module App.PageType exposing (Page(..))

{-| Prevent circular dependency.
-}


type alias ItemId =
    String


type Page
    = AccessDenied
    | Dashboard
    | Item ItemId
    | LoginPage
    | MyAccount
    | PageNotFound
