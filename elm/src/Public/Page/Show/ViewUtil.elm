module Page.Show.ViewUtil exposing (tabber, ShowScreen(..))

import Types exposing (..)
import Data.Types exposing (Slug)
import Html exposing (Html, ul, li, a, text)
import Html.Attributes exposing (href, class)


type ShowScreen
  = HomeScreen
  | EpisodeScreen
  | EventScreen
  | InfoScreen


tabber : Slug -> ShowScreen -> Bool -> List (Html Msg)
tabber slug screen showInfo =
  let
    showUrl =
      "#shows/" ++ slug
    items =
      [ ( "Home", showUrl, HomeScreen )
      , ( "Episodes", showUrl ++ "/episodes", EpisodeScreen )
      , ( "Events", showUrl ++ "/events", EventScreen )
      ]
      ++ case showInfo of
        True -> [( "Info", showUrl ++ "/info", InfoScreen )]
        False -> []
    htmls =
      List.map mapfunc items
    mapfunc ( name, url, curscreen ) =
      let
        bit =
          case curscreen == screen of
            True  -> " active"
            False -> ""
      in
        li [ class ("tab-item" ++ bit) ]
          [ a [ href url ] [ text name ] ]
  in
    [ ul [ class "tab tab-block" ] htmls ]

