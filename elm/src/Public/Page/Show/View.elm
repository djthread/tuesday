module Page.Show.View exposing (root)

import Html exposing (Html, text, ul, li, a)
import Html.Attributes exposing (class, href)
import Types exposing (..)
import Data.Types exposing (Slug, Show, ShowDetail, findShowBySlug)
import Data.EventsEpisodesColumnsView
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import Page.Show.ViewUtil exposing (tabber, ShowScreen(HomeScreen))
import Routing
import Markdown



root : String -> Model
    -> ( Crumbs, List (Html Msg) )
root slug model =
  case model.data.shows of
    Loaded shows ->
      case model.data.showDetail of
        Loaded showDetail ->
          case findShowBySlug shows slug of
            Just show ->
              ( [( show.name, "" )]
              , build slug model show showDetail
              )
            _ -> ViewUtil.wait
        _ -> ViewUtil.wait
    _ -> ViewUtil.wait


build : Slug -> Model -> Show -> ShowDetail
     -> List (Html Msg)
build slug model show detail =
  let
    hasInfo =
      not <| String.isEmpty detail.fullInfo
    tabs =
      tabber slug HomeScreen hasInfo
    shortInfo =
      [ Markdown.toHtml
          [ class "the-show-short" ]
          detail.shortInfo
      ]
    listings =
      Data.EventsEpisodesColumnsView.root
        model.data model.player show.slug
        (Routing.showEventsUrl show 1)
        (Routing.showEpisodesUrl show 1)
  in
    tabs ++ shortInfo ++ listings
