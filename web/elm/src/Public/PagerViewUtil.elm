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


-- type ViewType
--   = Episodes
--   | Events


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
                 -> ( Maybe Data.Types.Show, List (Html Msg) )
buildEpisodeList dataModel playerModel slug page conf =
  let
    ( conf2, shows ) =
      setup dataModel.shows slug page conf
    content =
      case dataModel.episodes of
        Loaded listing ->
          Data.EpisodeListView.root playerModel conf2 shows listing
        _ ->
          [ ViewUtil.waiting ]
  in
    ( conf2.show, content )


buildEventList : Data.Types.Model
                 -> String -> Int -> Data.Types.ListConfig
                 -> ( Maybe Data.Types.Show, List (Html Msg) )
buildEventList dataModel slug page conf =
  let
    ( conf2, shows ) =
      setup dataModel.shows slug page conf
    content =
      case dataModel.events of
        Loaded listing ->
          Data.EventListView.root conf2 shows listing
        _ ->
          [ ViewUtil.waiting ]
  in
    ( conf2.show, content )


buildCrumbs : Maybe Data.Types.Show -> Int -> Crumbs
buildCrumbs maybeShow page =
  case maybeShow of
    Just show -> crumbs show page
    Nothing   -> genericCrumbs page


crumbs : Data.Types.Show -> Int -> Crumbs
crumbs show page =
  [ (show.name, showUrl show.slug)
  , ("Episodes", episodesUrl (Just show) 1)
  , pageCrumb page
  ]


pageCrumb : Int -> Crumb
pageCrumb page =
  ("Page " ++ toString page, "")


genericCrumbs : Int -> Crumbs
genericCrumbs page =
  let
    ep = [ ("Episodes", "#episodes") ]
  in
    if page == 1 then ep else
      ep ++ [ pageCrumb page ]
