module Page.Show.View exposing (root, ShowScreen(..))

import Html exposing (Html, text, ul, li, a)
import Html.Attributes exposing (class, href)
import Types exposing (..)
import Data.Types exposing (Slug, Show, ShowDetail, findShowBySlug)
import Data.EventsEpisodesColumnsView
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import Routing


type ShowScreen
  = Home
  | Episodes
  | Events
  | Info


root : String -> Model -> ShowScreen
    -> ( Crumbs, List (Html Msg) )
root slug model screen =
  case model.data.shows of
    Loaded shows ->
      case model.data.showDetail of
        Loaded showDetail ->
          case findShowBySlug shows slug of
            Just show ->
              ( [( show.name, "" )]
              , build slug model screen show
              )
            _ -> waiting
        _ -> waiting
    _ -> waiting


waiting : ( Crumbs, List (Html Msg) )
waiting = ( [], [ ViewUtil.waiting ] )


build : Slug -> Model -> ShowScreen -> Show
     -> List (Html Msg)
build slug model screen show =
  let
    tabs =
      tabber slug screen
    listings =
      Data.EventsEpisodesColumnsView.root
        model.data model.player show.slug
        (Routing.showEventsUrl show 1)
        (Routing.showEpisodesUrl show 1)
  in
    tabs ++ listings


tabber : Slug -> ShowScreen -> List (Html Msg)
tabber slug screen =
  let
    showUrl =
      "#shows/" ++ slug
    items =
      [ ( "Home", showUrl, Home )
      , ( "Episodes", showUrl ++ "/episodes", Episodes )
      , ( "Events", showUrl ++ "/events", Events )
      , ( "Info", showUrl ++ "/info", Info )
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
