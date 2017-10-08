module App.PageType
    exposing
        ( Page
            ( AccessDenied
            , Dashboard
            , Item
            , Login
            , MyAccount
            , PageNotFound
            )
        )

{-| Prevent circular dependency.
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
