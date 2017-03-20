module PagerViewUtil exposing (..)

import Html exposing (Html)
-- import Html exposing (Html, Attribute, div, span, text, button, i, a, sup, ul, li)
-- import Html.Attributes exposing (style, class, attribute, href, target, disabled, tabindex)
-- import Html.Events exposing (onWithOptions, defaultOptions)
-- import Json.Decode
import Types exposing (..)
import Data.Types
import Data.Types exposing (findShowBySlug)
import Data.EpisodeListView
import Data.EventListView
import ViewUtil
-- import TypeUtil exposing (Pager)
-- import Date exposing (Date)
-- import Date.Format
import Routing exposing (..)
import TypeUtil exposing (RemoteData(Loaded))



setup : RemoteData (List Data.Types.Show) -> String -> Int
     -> Data.Types.ListConfig
     -> ( Data.Types.ListConfig, List Data.Types.Show )
setup rdShows slug page conf =
  case rdShows of
    Loaded shows ->
      let
        show = findShowBySlug shows slug
      in
        ( { conf | show = show }, shows )

    _ ->
        ( conf, [] )


buildEpisodeList : Data.Types.Model -> PlayerModel
                 -> String -> Int -> Data.Types.ListConfig
                 -> ( Maybe Data.Types.Show
                    , Maybe Data.Types.EpisodeListing
                    , List (Html Msg) )
buildEpisodeList dataModel playerModel slug page conf =
  let
    ( conf2, shows ) =
      setup dataModel.shows slug page conf
    ( episodes, content ) =
      case dataModel.episodes of
        Loaded listing ->
          ( Just listing
          , Data.EpisodeListView.root playerModel conf2 shows listing
          )
        _ ->
          ( Nothing, [ ViewUtil.waiting ] )
  in
    ( conf2.show, episodes, content )


buildEventList : Data.Types.Model
                 -> String -> Int -> Data.Types.ListConfig
                 -> ( Maybe Data.Types.Show
                    , Maybe Data.Types.EventListing
                    , List (Html Msg) )
buildEventList dataModel slug page conf =
  let
    ( conf2, shows ) =
      setup dataModel.shows slug page conf
    ( events, content ) =
      case dataModel.events of
        Loaded listing ->
          ( Just listing
          , Data.EventListView.root conf2 shows listing
          )
        _ ->
          ( Nothing, [ ViewUtil.waiting ] )
  in
    ( conf2.show, events, content )


buildCrumbs : NavSection
           -> Maybe Data.Types.Show -> Int
           -> Crumbs
buildCrumbs navSection maybeShow page =
  let
    pgOneOr str =
      if page == 1 then "" else str
  in
    case maybeShow of
      Just show ->
        let
          crumb =
            case navSection of
              Episodes ->
                ( "Episodes", pgOneOr (showEpisodesUrl show 1) )
              _ ->
                ( "Events", pgOneOr (showEventsUrl show 1) )
        in
          showCrumbs crumb show page

      Nothing ->
        let
          crumb =
            case navSection of
              Episodes ->
                ( "Episodes", pgOneOr "#episodes" )
              _ ->
                ( "Events", pgOneOr "#events" )
        in
          genericCrumbs crumb page


showCrumbs : Crumb -> Data.Types.Show -> Int -> Crumbs
showCrumbs crumb show page =
  [( show.name, showUrl show.slug )]
  ++ [crumb]
  ++ pageCrumb page


pageCrumb : Int -> Crumbs
pageCrumb page =
  if page == 0 then []
  else
    [("Page " ++ toString page, "")]


genericCrumbs : Crumb -> Int -> Crumbs
genericCrumbs crumb page =
  if page == 1 then [crumb] else
    [crumb] ++ pageCrumb page
