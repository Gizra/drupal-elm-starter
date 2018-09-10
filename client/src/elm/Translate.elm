module Translate exposing (HtmlTranslationId(..), Language(..), StringIdHttpError(..), StringIdItem(..), StringIdLogin(..), StringIdSidebar(..), StringTranslationId(..), TranslationSet, Url, allLanguages, languageFromCode, languageFromString, languageToCode, languageToString, selectTranslation, translateCountry, translateHtml, translateString, translateText)

import Country exposing (Country(..))
import Html exposing (Html, a, br, span, text)
import Html.Attributes exposing (class, href)


type Language
    = English
    | Hebrew
    | German


allLanguages : List Language
allLanguages =
    [ English
    , Hebrew
    , German
    ]


type alias TranslationSet a =
    { english : a
    , german : a
    , hebrew : a
    }


type alias Url =
    String



{- All translations fall into two categories: most are simple Strings, but some
   can contain arbitrary markup -- these return a list of Html. With the latter
   kind it's possible for a certain word in the translated text to be
   italicized, or made into a link, etc. (Not all `HtmlTranslationId`s take
   advantage of this yet.)
-}


{-| Translations that can have arbitrary markup within the translated phrase.
-}
type HtmlTranslationId
    = AgreedWithTerms Url


type StringIdHttpError
    = ErrorBadUrl
    | ErrorBadPayload String
    | ErrorBadStatus String
    | ErrorNetworkError
    | ErrorTimeout


type StringIdItem
    = Items
    | NoItemsFound
    | ReloadItem
    | SearchByName
    | Overview


type StringIdLogin
    = EnterYourPassword
    | EnterYourUsername
    | LoginVerb


type StringIdSidebar
    = Dashboard
    | Connected
    | NotConnected
    | SignOut


{-| Translations that are just plain Strings.
-}
type StringTranslationId
    = AccessDenied
    | HttpError StringIdHttpError
    | Item StringIdItem
    | Login StringIdLogin
    | PageNotFound
    | Sidebar StringIdSidebar


{-| Shorthand for the common case of
`translateText language TransId`.
-}
translateText : Language -> StringTranslationId -> Html msg
translateText language transId =
    text <| translateString language transId


{-| Translate as Html. Returns a `List` so it can be the second argument
to `p`, `div`, etc.
-}
translateHtml : Language -> HtmlTranslationId -> List (Html msg)
translateHtml language transId =
    let
        translationSet =
            case transId of
                AgreedWithTerms url ->
                    { english = [ text "I have read and accepted the Auctioneers' ", a [ href url ] [ text "Terms and Conditions" ], text " and I agree to abide by them." ]
                    , german = [ text "Ich habe die ", a [ href url ] [ text "AGB" ], text " gelesen und stimme ihnen zu" ]
                    , hebrew = [ text "קראתי והסכמתי עם ", a [ href url ] [ text "התנאים וההגבלות" ] ]
                    }
    in
    selectTranslation language translationSet
        |> List.map (Html.map never)


{-| Translate as a String.
-}
translateString : Language -> StringTranslationId -> String
translateString language transId =
    let
        translationSet =
            case transId of
                AccessDenied ->
                    { english = "Access Denied", german = "", hebrew = "" }

                HttpError stringId ->
                    case stringId of
                        ErrorBadUrl ->
                            { english = "URL is not valid.", german = "", hebrew = "כתובת שגוייה" }

                        ErrorBadPayload message ->
                            { english = "The server responded with data of an unexpected type: " ++ message, german = "" ++ message, hebrew = "השרת שלח מידע בלתי צפוי: " ++ message }

                        ErrorBadStatus err ->
                            { english = "The server indicated the following error:\n\n" ++ err, german = "", hebrew = "השרת שלך הודעת שגיאה:\n\n" ++ err }

                        ErrorNetworkError ->
                            { english = "There was a network error.", german = "", hebrew = "בעיית רשת" }

                        ErrorTimeout ->
                            { english = "The network request timed out.", german = "", hebrew = "הקריאה לשרת ארכה זמן רב מדי" }

                Item stringId ->
                    case stringId of
                        Items ->
                            { english = "Items", german = "", hebrew = "" }

                        NoItemsFound ->
                            { english = "No Items Found", german = "", hebrew = "" }

                        ReloadItem ->
                            { english = "Reload Item", german = "", hebrew = "" }

                        SearchByName ->
                            { english = "Search By Name", german = "", hebrew = "" }

                        Overview ->
                            { english = "Overview", german = "", hebrew = "" }

                Login stringId ->
                    case stringId of
                        EnterYourPassword ->
                            { english = "Enter your password", german = "Bitte geben Sie Ihr Passwort ein", hebrew = "הכניסו את סיסמתכם" }

                        EnterYourUsername ->
                            { english = "Enter your username", german = "Ihr Benutzername", hebrew = "שם המשתמש" }

                        LoginVerb ->
                            { english = "Login", german = "Anmeldung", hebrew = "התחברות" }

                PageNotFound ->
                    { english = "Page Not Found", german = "", hebrew = "" }

                Sidebar stringId ->
                    case stringId of
                        Dashboard ->
                            { english = "Dashboard", german = "", hebrew = "" }

                        Connected ->
                            { english = "Connected", german = "", hebrew = "" }

                        NotConnected ->
                            { english = "Not Connected", german = "", hebrew = "" }

                        SignOut ->
                            { english = "Sign Out", german = "", hebrew = "" }
    in
    selectTranslation language translationSet


selectTranslation : Language -> TranslationSet a -> a
selectTranslation lang transSet =
    case lang of
        English ->
            .english transSet

        German ->
            .german transSet

        Hebrew ->
            .hebrew transSet


languageFromString : String -> Result String Language
languageFromString str =
    case str of
        "English" ->
            Ok English

        "German" ->
            Ok German

        "Hebrew" ->
            Ok Hebrew

        _ ->
            Err "Not a language"


languageFromCode : String -> Result String Language
languageFromCode str =
    case str of
        "en" ->
            Ok English

        "de" ->
            Ok German

        "he" ->
            Ok Hebrew

        _ ->
            Err "Not a language"


languageToCode : Language -> String
languageToCode lang =
    case lang of
        English ->
            "en"

        German ->
            "de"

        Hebrew ->
            "he"


languageToString : Language -> String
languageToString lang =
    case lang of
        English ->
            "English"

        German ->
            "Deutsch"

        Hebrew ->
            "עברית"


translateCountry : Country -> TranslationSet String
translateCountry country =
    case country of
        AC ->
            { english = "Ascension Island"
            , german = "Ascension"
            , hebrew = "האי אסנשן"
            }

        AD ->
            { english = "Andorra"
            , german = "Andorra"
            , hebrew = "אנדורה"
            }

        AE ->
            { english = "United Arab Emirates"
            , german = "Vereinigte Arabische Emirate"
            , hebrew = "איחוד האמירויות הערביות"
            }

        AF ->
            { english = "Afghanistan"
            , german = "Afghanistan"
            , hebrew = "אפגניסטן"
            }

        AG ->
            { english = "Antigua & Barbuda"
            , german = "Antigua und Barbuda"
            , hebrew = "אנטיגואה וברבודה"
            }

        AI ->
            { english = "Anguilla"
            , german = "Anguilla"
            , hebrew = "אנגילה"
            }

        AL ->
            { english = "Albania"
            , german = "Albanien"
            , hebrew = "אלבניה"
            }

        AM ->
            { english = "Armenia"
            , german = "Armenien"
            , hebrew = "ארמניה"
            }

        AO ->
            { english = "Angola"
            , german = "Angola"
            , hebrew = "אנגולה"
            }

        AQ ->
            { english = "Antarctica"
            , german = "Antarktis"
            , hebrew = "אנטארקטיקה"
            }

        AR ->
            { english = "Argentina"
            , german = "Argentinien"
            , hebrew = "ארגנטינה"
            }

        AS ->
            { english = "American Samoa"
            , german = "Amerikanisch-Samoa"
            , hebrew = "סמואה האמריקנית"
            }

        AT ->
            { english = "Austria"
            , german = "Österreich"
            , hebrew = "אוסטריה"
            }

        AU ->
            { english = "Australia"
            , german = "Australien"
            , hebrew = "אוסטרליה"
            }

        AW ->
            { english = "Aruba"
            , german = "Aruba"
            , hebrew = "ארובה"
            }

        AX ->
            { english = "Åland Islands"
            , german = "Ålandinseln"
            , hebrew = "איי אולנד"
            }

        AZ ->
            { english = "Azerbaijan"
            , german = "Aserbaidschan"
            , hebrew = "אזרבייג׳ן"
            }

        BA ->
            { english = "Bosnia & Herzegovina"
            , german = "Bosnien und Herzegowina"
            , hebrew = "בוסניה והרצגובינה"
            }

        BB ->
            { english = "Barbados"
            , german = "Barbados"
            , hebrew = "ברבדוס"
            }

        BD ->
            { english = "Bangladesh"
            , german = "Bangladesch"
            , hebrew = "בנגלדש"
            }

        BE ->
            { english = "Belgium"
            , german = "Belgien"
            , hebrew = "בלגיה"
            }

        BF ->
            { english = "Burkina Faso"
            , german = "Burkina Faso"
            , hebrew = "בורקינה פאסו"
            }

        BG ->
            { english = "Bulgaria"
            , german = "Bulgarien"
            , hebrew = "בולגריה"
            }

        BH ->
            { english = "Bahrain"
            , german = "Bahrain"
            , hebrew = "בחריין"
            }

        BI ->
            { english = "Burundi"
            , german = "Burundi"
            , hebrew = "בורונדי"
            }

        BJ ->
            { english = "Benin"
            , german = "Benin"
            , hebrew = "בנין"
            }

        BL ->
            { english = "St. Barthélemy"
            , german = "St. Barthélemy"
            , hebrew = "סנט ברתולומיאו"
            }

        BM ->
            { english = "Bermuda"
            , german = "Bermuda"
            , hebrew = "ברמודה"
            }

        BN ->
            { english = "Brunei"
            , german = "Brunei Darussalam"
            , hebrew = "ברוניי"
            }

        BO ->
            { english = "Bolivia"
            , german = "Bolivien"
            , hebrew = "בוליביה"
            }

        BQ ->
            { english = "Caribbean Netherlands"
            , german = "Bonaire, Sint Eustatius und Saba"
            , hebrew = "האיים הקריביים ההולנדיים"
            }

        BR ->
            { english = "Brazil"
            , german = "Brasilien"
            , hebrew = "ברזיל"
            }

        BS ->
            { english = "Bahamas"
            , german = "Bahamas"
            , hebrew = "איי בהאמה"
            }

        BT ->
            { english = "Bhutan"
            , german = "Bhutan"
            , hebrew = "בהוטן"
            }

        BV ->
            { english = "Bouvet Island"
            , german = "Bouvetinsel"
            , hebrew = "איי בובה"
            }

        BW ->
            { english = "Botswana"
            , german = "Botsuana"
            , hebrew = "בוצוואנה"
            }

        BY ->
            { english = "Belarus"
            , german = "Belarus"
            , hebrew = "בלארוס"
            }

        BZ ->
            { english = "Belize"
            , german = "Belize"
            , hebrew = "בליז"
            }

        CA ->
            { english = "Canada"
            , german = "Kanada"
            , hebrew = "קנדה"
            }

        CC ->
            { english = "Cocos (Keeling) Islands"
            , german = "Kokosinseln"
            , hebrew = "איי קוקוס (קילינג)"
            }

        CD ->
            { english = "Congo - Kinshasa"
            , german = "Kongo-Kinshasa"
            , hebrew = "קונגו - קינשאסה"
            }

        CF ->
            { english = "Central African Republic"
            , german = "Zentralafrikanische Republik"
            , hebrew = "הרפובליקה של מרכז אפריקה"
            }

        CG ->
            { english = "Congo - Brazzaville"
            , german = "Kongo-Brazzaville"
            , hebrew = "קונגו - ברזאויל"
            }

        CH ->
            { english = "Switzerland"
            , german = "Schweiz"
            , hebrew = "שווייץ"
            }

        CI ->
            { english = "Côte d’Ivoire"
            , german = "Côte d’Ivoire"
            , hebrew = "חוף השנהב"
            }

        CK ->
            { english = "Cook Islands"
            , german = "Cookinseln"
            , hebrew = "איי קוק"
            }

        CL ->
            { english = "Chile"
            , german = "Chile"
            , hebrew = "צ׳ילה"
            }

        CM ->
            { english = "Cameroon"
            , german = "Kamerun"
            , hebrew = "קמרון"
            }

        CN ->
            { english = "China"
            , german = "China"
            , hebrew = "סין"
            }

        CO ->
            { english = "Colombia"
            , german = "Kolumbien"
            , hebrew = "קולומביה"
            }

        CP ->
            { english = "Clipperton Island"
            , german = "Clipperton-Insel"
            , hebrew = "האי קליפרטון"
            }

        CR ->
            { english = "Costa Rica"
            , german = "Costa Rica"
            , hebrew = "קוסטה ריקה"
            }

        CU ->
            { english = "Cuba"
            , german = "Kuba"
            , hebrew = "קובה"
            }

        CV ->
            { english = "Cape Verde"
            , german = "Cabo Verde"
            , hebrew = "כף ורדה"
            }

        CW ->
            { english = "Curaçao"
            , german = "Curaçao"
            , hebrew = "קוראסאו"
            }

        CX ->
            { english = "Christmas Island"
            , german = "Weihnachtsinsel"
            , hebrew = "האי כריסטמס"
            }

        CY ->
            { english = "Cyprus"
            , german = "Zypern"
            , hebrew = "קפריסין"
            }

        CZ ->
            { english = "Czechia"
            , german = "Tschechien"
            , hebrew = "צ׳כיה"
            }

        DE ->
            { english = "Germany"
            , german = "Deutschland"
            , hebrew = "גרמניה"
            }

        DG ->
            { english = "Diego Garcia"
            , german = "Diego Garcia"
            , hebrew = "דייגו גרסיה"
            }

        DJ ->
            { english = "Djibouti"
            , german = "Dschibuti"
            , hebrew = "ג׳יבוטי"
            }

        DK ->
            { english = "Denmark"
            , german = "Dänemark"
            , hebrew = "דנמרק"
            }

        DM ->
            { english = "Dominica"
            , german = "Dominica"
            , hebrew = "דומיניקה"
            }

        DO ->
            { english = "Dominican Republic"
            , german = "Dominikanische Republik"
            , hebrew = "הרפובליקה הדומיניקנית"
            }

        DZ ->
            { english = "Algeria"
            , german = "Algerien"
            , hebrew = "אלג׳יריה"
            }

        EA ->
            { english = "Ceuta & Melilla"
            , german = "Ceuta und Melilla"
            , hebrew = "סאוטה ומלייה"
            }

        EC ->
            { english = "Ecuador"
            , german = "Ecuador"
            , hebrew = "אקוודור"
            }

        EE ->
            { english = "Estonia"
            , german = "Estland"
            , hebrew = "אסטוניה"
            }

        EG ->
            { english = "Egypt"
            , german = "Ägypten"
            , hebrew = "מצרים"
            }

        EH ->
            { english = "Western Sahara"
            , german = "Westsahara"
            , hebrew = "סהרה המערבית"
            }

        ER ->
            { english = "Eritrea"
            , german = "Eritrea"
            , hebrew = "אריתריאה"
            }

        ES ->
            { english = "Spain"
            , german = "Spanien"
            , hebrew = "ספרד"
            }

        ET ->
            { english = "Ethiopia"
            , german = "Äthiopien"
            , hebrew = "אתיופיה"
            }

        EU ->
            { english = "European Union"
            , german = "Europäische Union"
            , hebrew = "האיחוד האירופי"
            }

        EZ ->
            { english = "Eurozone"
            , german = "EZ"
            , hebrew = "EZ"
            }

        FI ->
            { english = "Finland"
            , german = "Finnland"
            , hebrew = "פינלנד"
            }

        FJ ->
            { english = "Fiji"
            , german = "Fidschi"
            , hebrew = "פיג׳י"
            }

        FK ->
            { english = "Falkland Islands"
            , german = "Falklandinseln"
            , hebrew = "איי פוקלנד"
            }

        FM ->
            { english = "Micronesia"
            , german = "Mikronesien"
            , hebrew = "מיקרונזיה"
            }

        FO ->
            { english = "Faroe Islands"
            , german = "Färöer"
            , hebrew = "איי פארו"
            }

        FR ->
            { english = "France"
            , german = "Frankreich"
            , hebrew = "צרפת"
            }

        GA ->
            { english = "Gabon"
            , german = "Gabun"
            , hebrew = "גבון"
            }

        GB ->
            { english = "United Kingdom"
            , german = "Vereinigtes Königreich"
            , hebrew = "הממלכה המאוחדת"
            }

        GD ->
            { english = "Grenada"
            , german = "Grenada"
            , hebrew = "גרנדה"
            }

        GE ->
            { english = "Georgia"
            , german = "Georgien"
            , hebrew = "גאורגיה"
            }

        GF ->
            { english = "French Guiana"
            , german = "Französisch-Guayana"
            , hebrew = "גיאנה הצרפתית"
            }

        GG ->
            { english = "Guernsey"
            , german = "Guernsey"
            , hebrew = "גרנסי"
            }

        GH ->
            { english = "Ghana"
            , german = "Ghana"
            , hebrew = "גאנה"
            }

        GI ->
            { english = "Gibraltar"
            , german = "Gibraltar"
            , hebrew = "גיברלטר"
            }

        GL ->
            { english = "Greenland"
            , german = "Grönland"
            , hebrew = "גרינלנד"
            }

        GM ->
            { english = "Gambia"
            , german = "Gambia"
            , hebrew = "גמביה"
            }

        GN ->
            { english = "Guinea"
            , german = "Guinea"
            , hebrew = "גינאה"
            }

        GP ->
            { english = "Guadeloupe"
            , german = "Guadeloupe"
            , hebrew = "גוואדלופ"
            }

        GQ ->
            { english = "Equatorial Guinea"
            , german = "Äquatorialguinea"
            , hebrew = "גינאה המשוונית"
            }

        GR ->
            { english = "Greece"
            , german = "Griechenland"
            , hebrew = "יוון"
            }

        GS ->
            { english = "South Georgia & South Sandwich Islands"
            , german = "Südgeorgien und die Südlichen Sandwichinseln"
            , hebrew = "ג׳ורג׳יה הדרומית ואיי סנדוויץ׳ הדרומיים"
            }

        Country.GT ->
            { english = "Guatemala"
            , german = "Guatemala"
            , hebrew = "גואטמלה"
            }

        GU ->
            { english = "Guam"
            , german = "Guam"
            , hebrew = "גואם"
            }

        GW ->
            { english = "Guinea-Bissau"
            , german = "Guinea-Bissau"
            , hebrew = "גינאה ביסאו"
            }

        GY ->
            { english = "Guyana"
            , german = "Guyana"
            , hebrew = "גיאנה"
            }

        HK ->
            { english = "Hong Kong SAR China"
            , german = "Sonderverwaltungszone Hongkong"
            , hebrew = "הונג קונג (מחוז מנהלי מיוחד של סין)"
            }

        HM ->
            { english = "Heard & McDonald Islands"
            , german = "Heard und McDonaldinseln"
            , hebrew = "איי הרד ומקדונלד"
            }

        HN ->
            { english = "Honduras"
            , german = "Honduras"
            , hebrew = "הונדורס"
            }

        HR ->
            { english = "Croatia"
            , german = "Kroatien"
            , hebrew = "קרואטיה"
            }

        HT ->
            { english = "Haiti"
            , german = "Haiti"
            , hebrew = "האיטי"
            }

        HU ->
            { english = "Hungary"
            , german = "Ungarn"
            , hebrew = "הונגריה"
            }

        IC ->
            { english = "Canary Islands"
            , german = "Kanarische Inseln"
            , hebrew = "האיים הקנריים"
            }

        ID ->
            { english = "Indonesia"
            , german = "Indonesien"
            , hebrew = "אינדונזיה"
            }

        IE ->
            { english = "Ireland"
            , german = "Irland"
            , hebrew = "אירלנד"
            }

        IL ->
            { english = "Israel"
            , german = "Israel"
            , hebrew = "ישראל"
            }

        IM ->
            { english = "Isle of Man"
            , german = "Isle of Man"
            , hebrew = "האי מאן"
            }

        IN ->
            { english = "India"
            , german = "Indien"
            , hebrew = "הודו"
            }

        IO ->
            { english = "British Indian Ocean Territory"
            , german = "Britisches Territorium im Indischen Ozean"
            , hebrew = "הטריטוריה הבריטית באוקיינוס ההודי"
            }

        IQ ->
            { english = "Iraq"
            , german = "Irak"
            , hebrew = "עיראק"
            }

        IR ->
            { english = "Iran"
            , german = "Iran"
            , hebrew = "איראן"
            }

        IS ->
            { english = "Iceland"
            , german = "Island"
            , hebrew = "איסלנד"
            }

        IT ->
            { english = "Italy"
            , german = "Italien"
            , hebrew = "איטליה"
            }

        JE ->
            { english = "Jersey"
            , german = "Jersey"
            , hebrew = "ג׳רסי"
            }

        JM ->
            { english = "Jamaica"
            , german = "Jamaika"
            , hebrew = "ג׳מייקה"
            }

        JO ->
            { english = "Jordan"
            , german = "Jordanien"
            , hebrew = "ירדן"
            }

        JP ->
            { english = "Japan"
            , german = "Japan"
            , hebrew = "יפן"
            }

        KE ->
            { english = "Kenya"
            , german = "Kenia"
            , hebrew = "קניה"
            }

        KG ->
            { english = "Kyrgyzstan"
            , german = "Kirgisistan"
            , hebrew = "קירגיזסטן"
            }

        KH ->
            { english = "Cambodia"
            , german = "Kambodscha"
            , hebrew = "קמבודיה"
            }

        KI ->
            { english = "Kiribati"
            , german = "Kiribati"
            , hebrew = "קיריבאטי"
            }

        KM ->
            { english = "Comoros"
            , german = "Komoren"
            , hebrew = "קומורו"
            }

        KN ->
            { english = "St. Kitts & Nevis"
            , german = "St. Kitts und Nevis"
            , hebrew = "סנט קיטס ונוויס"
            }

        KP ->
            { english = "North Korea"
            , german = "Nordkorea"
            , hebrew = "קוריאה הצפונית"
            }

        KR ->
            { english = "South Korea"
            , german = "Südkorea"
            , hebrew = "קוריאה הדרומית"
            }

        KW ->
            { english = "Kuwait"
            , german = "Kuwait"
            , hebrew = "כווית"
            }

        KY ->
            { english = "Cayman Islands"
            , german = "Kaimaninseln"
            , hebrew = "איי קיימן"
            }

        KZ ->
            { english = "Kazakhstan"
            , german = "Kasachstan"
            , hebrew = "קזחסטן"
            }

        LA ->
            { english = "Laos"
            , german = "Laos"
            , hebrew = "לאוס"
            }

        LB ->
            { english = "Lebanon"
            , german = "Libanon"
            , hebrew = "לבנון"
            }

        LC ->
            { english = "St. Lucia"
            , german = "St. Lucia"
            , hebrew = "סנט לוסיה"
            }

        LI ->
            { english = "Liechtenstein"
            , german = "Liechtenstein"
            , hebrew = "ליכטנשטיין"
            }

        LK ->
            { english = "Sri Lanka"
            , german = "Sri Lanka"
            , hebrew = "סרי לנקה"
            }

        LR ->
            { english = "Liberia"
            , german = "Liberia"
            , hebrew = "ליבריה"
            }

        LS ->
            { english = "Lesotho"
            , german = "Lesotho"
            , hebrew = "לסוטו"
            }

        Country.LT ->
            { english = "Lithuania"
            , german = "Litauen"
            , hebrew = "ליטא"
            }

        LU ->
            { english = "Luxembourg"
            , german = "Luxemburg"
            , hebrew = "לוקסמבורג"
            }

        LV ->
            { english = "Latvia"
            , german = "Lettland"
            , hebrew = "לטביה"
            }

        LY ->
            { english = "Libya"
            , german = "Libyen"
            , hebrew = "לוב"
            }

        MA ->
            { english = "Morocco"
            , german = "Marokko"
            , hebrew = "מרוקו"
            }

        MC ->
            { english = "Monaco"
            , german = "Monaco"
            , hebrew = "מונקו"
            }

        MD ->
            { english = "Moldova"
            , german = "Republik Moldau"
            , hebrew = "מולדובה"
            }

        ME ->
            { english = "Montenegro"
            , german = "Montenegro"
            , hebrew = "מונטנגרו"
            }

        MF ->
            { english = "St. Martin"
            , german = "St. Martin"
            , hebrew = "סן מרטן"
            }

        MG ->
            { english = "Madagascar"
            , german = "Madagaskar"
            , hebrew = "מדגסקר"
            }

        MH ->
            { english = "Marshall Islands"
            , german = "Marshallinseln"
            , hebrew = "איי מרשל"
            }

        MK ->
            { english = "Macedonia"
            , german = "Mazedonien"
            , hebrew = "מקדוניה"
            }

        ML ->
            { english = "Mali"
            , german = "Mali"
            , hebrew = "מאלי"
            }

        MM ->
            { english = "Myanmar (Burma)"
            , german = "Myanmar"
            , hebrew = "מיאנמר (בורמה)"
            }

        MN ->
            { english = "Mongolia"
            , german = "Mongolei"
            , hebrew = "מונגוליה"
            }

        MO ->
            { english = "Macau SAR China"
            , german = "Sonderverwaltungsregion Macau"
            , hebrew = "מקאו (מחוז מנהלי מיוחד של סין)"
            }

        MP ->
            { english = "Northern Mariana Islands"
            , german = "Nördliche Marianen"
            , hebrew = "איי מריאנה הצפוניים"
            }

        MQ ->
            { english = "Martinique"
            , german = "Martinique"
            , hebrew = "מרטיניק"
            }

        MR ->
            { english = "Mauritania"
            , german = "Mauretanien"
            , hebrew = "מאוריטניה"
            }

        MS ->
            { english = "Montserrat"
            , german = "Montserrat"
            , hebrew = "מונסראט"
            }

        MT ->
            { english = "Malta"
            , german = "Malta"
            , hebrew = "מלטה"
            }

        MU ->
            { english = "Mauritius"
            , german = "Mauritius"
            , hebrew = "מאוריציוס"
            }

        MV ->
            { english = "Maldives"
            , german = "Malediven"
            , hebrew = "האיים המלדיביים"
            }

        MW ->
            { english = "Malawi"
            , german = "Malawi"
            , hebrew = "מלאווי"
            }

        MX ->
            { english = "Mexico"
            , german = "Mexiko"
            , hebrew = "מקסיקו"
            }

        MY ->
            { english = "Malaysia"
            , german = "Malaysia"
            , hebrew = "מלזיה"
            }

        MZ ->
            { english = "Mozambique"
            , german = "Mosambik"
            , hebrew = "מוזמביק"
            }

        NA ->
            { english = "Namibia"
            , german = "Namibia"
            , hebrew = "נמיביה"
            }

        NC ->
            { english = "New Caledonia"
            , german = "Neukaledonien"
            , hebrew = "קלדוניה החדשה"
            }

        NE ->
            { english = "Niger"
            , german = "Niger"
            , hebrew = "ניז׳ר"
            }

        NF ->
            { english = "Norfolk Island"
            , german = "Norfolkinsel"
            , hebrew = "איי נורפוק"
            }

        NG ->
            { english = "Nigeria"
            , german = "Nigeria"
            , hebrew = "ניגריה"
            }

        NI ->
            { english = "Nicaragua"
            , german = "Nicaragua"
            , hebrew = "ניקרגואה"
            }

        NL ->
            { english = "Netherlands"
            , german = "Niederlande"
            , hebrew = "הולנד"
            }

        NO ->
            { english = "Norway"
            , german = "Norwegen"
            , hebrew = "נורווגיה"
            }

        NP ->
            { english = "Nepal"
            , german = "Nepal"
            , hebrew = "נפאל"
            }

        NR ->
            { english = "Nauru"
            , german = "Nauru"
            , hebrew = "נאורו"
            }

        NU ->
            { english = "Niue"
            , german = "Niue"
            , hebrew = "ניווה"
            }

        NZ ->
            { english = "New Zealand"
            , german = "Neuseeland"
            , hebrew = "ניו זילנד"
            }

        OM ->
            { english = "Oman"
            , german = "Oman"
            , hebrew = "עומאן"
            }

        PA ->
            { english = "Panama"
            , german = "Panama"
            , hebrew = "פנמה"
            }

        PE ->
            { english = "Peru"
            , german = "Peru"
            , hebrew = "פרו"
            }

        PF ->
            { english = "French Polynesia"
            , german = "Französisch-Polynesien"
            , hebrew = "פולינזיה הצרפתית"
            }

        PG ->
            { english = "Papua New Guinea"
            , german = "Papua-Neuguinea"
            , hebrew = "פפואה גינאה החדשה"
            }

        PH ->
            { english = "Philippines"
            , german = "Philippinen"
            , hebrew = "הפיליפינים"
            }

        PK ->
            { english = "Pakistan"
            , german = "Pakistan"
            , hebrew = "פקיסטן"
            }

        PL ->
            { english = "Poland"
            , german = "Polen"
            , hebrew = "פולין"
            }

        PM ->
            { english = "St. Pierre & Miquelon"
            , german = "St. Pierre und Miquelon"
            , hebrew = "סנט פייר ומיקלון"
            }

        PN ->
            { english = "Pitcairn Islands"
            , german = "Pitcairninseln"
            , hebrew = "איי פיטקרן"
            }

        PR ->
            { english = "Puerto Rico"
            , german = "Puerto Rico"
            , hebrew = "פוארטו ריקו"
            }

        PS ->
            { english = "Palestinian Territories"
            , german = "Palästinensische Autonomiegebiete"
            , hebrew = "השטחים הפלסטיניים"
            }

        PT ->
            { english = "Portugal"
            , german = "Portugal"
            , hebrew = "פורטוגל"
            }

        PW ->
            { english = "Palau"
            , german = "Palau"
            , hebrew = "פלאו"
            }

        PY ->
            { english = "Paraguay"
            , german = "Paraguay"
            , hebrew = "פרגוואי"
            }

        QA ->
            { english = "Qatar"
            , german = "Katar"
            , hebrew = "קטאר"
            }

        QO ->
            { english = "Outlying Oceania"
            , german = "Äußeres Ozeanien"
            , hebrew = "טריטוריות באוקיאניה"
            }

        RE ->
            { english = "Réunion"
            , german = "Réunion"
            , hebrew = "ראוניון"
            }

        RO ->
            { english = "Romania"
            , german = "Rumänien"
            , hebrew = "רומניה"
            }

        RS ->
            { english = "Serbia"
            , german = "Serbien"
            , hebrew = "סרביה"
            }

        RU ->
            { english = "Russia"
            , german = "Russland"
            , hebrew = "רוסיה"
            }

        RW ->
            { english = "Rwanda"
            , german = "Ruanda"
            , hebrew = "רואנדה"
            }

        SA ->
            { english = "Saudi Arabia"
            , german = "Saudi-Arabien"
            , hebrew = "ערב הסעודית"
            }

        SB ->
            { english = "Solomon Islands"
            , german = "Salomonen"
            , hebrew = "איי שלמה"
            }

        SC ->
            { english = "Seychelles"
            , german = "Seychellen"
            , hebrew = "איי סיישל"
            }

        SD ->
            { english = "Sudan"
            , german = "Sudan"
            , hebrew = "סודן"
            }

        SE ->
            { english = "Sweden"
            , german = "Schweden"
            , hebrew = "שוודיה"
            }

        SG ->
            { english = "Singapore"
            , german = "Singapur"
            , hebrew = "סינגפור"
            }

        SH ->
            { english = "St. Helena"
            , german = "St. Helena"
            , hebrew = "סנט הלנה"
            }

        SI ->
            { english = "Slovenia"
            , german = "Slowenien"
            , hebrew = "סלובניה"
            }

        SJ ->
            { english = "Svalbard & Jan Mayen"
            , german = "Spitzbergen"
            , hebrew = "סוולבארד ויאן מאיין"
            }

        SK ->
            { english = "Slovakia"
            , german = "Slowakei"
            , hebrew = "סלובקיה"
            }

        SL ->
            { english = "Sierra Leone"
            , german = "Sierra Leone"
            , hebrew = "סיירה לאונה"
            }

        SM ->
            { english = "San Marino"
            , german = "San Marino"
            , hebrew = "סן מרינו"
            }

        SN ->
            { english = "Senegal"
            , german = "Senegal"
            , hebrew = "סנגל"
            }

        SO ->
            { english = "Somalia"
            , german = "Somalia"
            , hebrew = "סומליה"
            }

        SR ->
            { english = "Suriname"
            , german = "Suriname"
            , hebrew = "סורינם"
            }

        SS ->
            { english = "South Sudan"
            , german = "Südsudan"
            , hebrew = "דרום סודן"
            }

        ST ->
            { english = "São Tomé & Príncipe"
            , german = "São Tomé und Príncipe"
            , hebrew = "סאו טומה ופרינסיפה"
            }

        SV ->
            { english = "El Salvador"
            , german = "El Salvador"
            , hebrew = "אל סלבדור"
            }

        SX ->
            { english = "Sint Maarten"
            , german = "Sint Maarten"
            , hebrew = "סנט מארטן"
            }

        SY ->
            { english = "Syria"
            , german = "Syrien"
            , hebrew = "סוריה"
            }

        SZ ->
            { english = "Swaziland"
            , german = "Swasiland"
            , hebrew = "סווזילנד"
            }

        TA ->
            { english = "Tristan da Cunha"
            , german = "Tristan da Cunha"
            , hebrew = "טריסטן דה קונה"
            }

        TC ->
            { english = "Turks & Caicos Islands"
            , german = "Turks- und Caicosinseln"
            , hebrew = "איי טורקס וקאיקוס"
            }

        TD ->
            { english = "Chad"
            , german = "Tschad"
            , hebrew = "צ׳אד"
            }

        TF ->
            { english = "French Southern Territories"
            , german = "Französische Süd- und Antarktisgebiete"
            , hebrew = "הטריטוריות הדרומיות של צרפת"
            }

        TG ->
            { english = "Togo"
            , german = "Togo"
            , hebrew = "טוגו"
            }

        TH ->
            { english = "Thailand"
            , german = "Thailand"
            , hebrew = "תאילנד"
            }

        TJ ->
            { english = "Tajikistan"
            , german = "Tadschikistan"
            , hebrew = "טג׳יקיסטן"
            }

        TK ->
            { english = "Tokelau"
            , german = "Tokelau"
            , hebrew = "טוקלאו"
            }

        TL ->
            { english = "Timor-Leste"
            , german = "Osttimor"
            , hebrew = "טימור לסטה"
            }

        TM ->
            { english = "Turkmenistan"
            , german = "Turkmenistan"
            , hebrew = "טורקמניסטן"
            }

        TN ->
            { english = "Tunisia"
            , german = "Tunesien"
            , hebrew = "טוניסיה"
            }

        TO ->
            { english = "Tonga"
            , german = "Tonga"
            , hebrew = "טונגה"
            }

        TR ->
            { english = "Turkey"
            , german = "Türkei"
            , hebrew = "טורקיה"
            }

        TT ->
            { english = "Trinidad & Tobago"
            , german = "Trinidad und Tobago"
            , hebrew = "טרינידד וטובגו"
            }

        TV ->
            { english = "Tuvalu"
            , german = "Tuvalu"
            , hebrew = "טובאלו"
            }

        TW ->
            { english = "Taiwan"
            , german = "Taiwan"
            , hebrew = "טייוואן"
            }

        TZ ->
            { english = "Tanzania"
            , german = "Tansania"
            , hebrew = "טנזניה"
            }

        UA ->
            { english = "Ukraine"
            , german = "Ukraine"
            , hebrew = "אוקראינה"
            }

        UG ->
            { english = "Uganda"
            , german = "Uganda"
            , hebrew = "אוגנדה"
            }

        UM ->
            { english = "U.S. Outlying Islands"
            , german = "Amerikanische Überseeinseln"
            , hebrew = "האיים המרוחקים הקטנים של ארה״ב"
            }

        UN ->
            { english = "United Nations"
            , german = "Vereinte Nationen"
            , hebrew = "האומות המאוחדות"
            }

        US ->
            { english = "United States"
            , german = "Vereinigte Staaten"
            , hebrew = "ארצות הברית"
            }

        UY ->
            { english = "Uruguay"
            , german = "Uruguay"
            , hebrew = "אורוגוואי"
            }

        UZ ->
            { english = "Uzbekistan"
            , german = "Usbekistan"
            , hebrew = "אוזבקיסטן"
            }

        VA ->
            { english = "Vatican City"
            , german = "Vatikanstadt"
            , hebrew = "הוותיקן"
            }

        VC ->
            { english = "St. Vincent & Grenadines"
            , german = "St. Vincent und die Grenadinen"
            , hebrew = "סנט וינסנט והגרנדינים"
            }

        VE ->
            { english = "Venezuela"
            , german = "Venezuela"
            , hebrew = "ונצואלה"
            }

        VG ->
            { english = "British Virgin Islands"
            , german = "Britische Jungferninseln"
            , hebrew = "איי הבתולה הבריטיים"
            }

        VI ->
            { english = "U.S. Virgin Islands"
            , german = "Amerikanische Jungferninseln"
            , hebrew = "איי הבתולה של ארצות הברית"
            }

        VN ->
            { english = "Vietnam"
            , german = "Vietnam"
            , hebrew = "וייטנאם"
            }

        VU ->
            { english = "Vanuatu"
            , german = "Vanuatu"
            , hebrew = "ונואטו"
            }

        WF ->
            { english = "Wallis & Futuna"
            , german = "Wallis und Futuna"
            , hebrew = "איי ווליס ופוטונה"
            }

        WS ->
            { english = "Samoa"
            , german = "Samoa"
            , hebrew = "סמואה"
            }

        XK ->
            { english = "Kosovo"
            , german = "Kosovo"
            , hebrew = "קוסובו"
            }

        YE ->
            { english = "Yemen"
            , german = "Jemen"
            , hebrew = "תימן"
            }

        YT ->
            { english = "Mayotte"
            , german = "Mayotte"
            , hebrew = "מאיוט"
            }

        ZA ->
            { english = "South Africa"
            , german = "Südafrika"
            , hebrew = "דרום אפריקה"
            }

        ZM ->
            { english = "Zambia"
            , german = "Sambia"
            , hebrew = "זמביה"
            }

        ZW ->
            { english = "Zimbabwe"
            , german = "Simbabwe"
            , hebrew = "זימבבואה"
            }
