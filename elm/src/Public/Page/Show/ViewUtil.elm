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


tabber : Slug -> ShowScreen -> List (Html Msg)
tabber slug screen =
  let
    showUrl =
      "#shows/" ++ slug
    items =
      [ ( "Home", showUrl, HomeScreen )
      , ( "Episodes", showUrl ++ "/episodes", EpisodeScreen )
      , ( "Events", showUrl ++ "/events", EventScreen )
      , ( "Info", showUrl ++ "/info", InfoScreen )
      ]
        |> List.map mapfunc
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
    [ ul [ class "tab tab-block" ] items ]

