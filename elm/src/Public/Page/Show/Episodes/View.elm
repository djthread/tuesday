module Page.Show.Episodes.View exposing (root)

import Html exposing (Html)
import Types exposing (..)
import PagerViewUtil
import Page.Show.ViewUtil exposing (tabber, ShowScreen(EpisodeScreen))

root : Model -> String -> Int -> ( Crumbs, List (Html Msg) )
root model slug page =
  let
    ( maybeShow, _, content ) =
      PagerViewUtil.buildEpisodeList
        model.data model.player slug page
        { paginate = True
        , show = Nothing
        , only = Nothing
        , linkTitle = True
        }
    tabs =
      tabber slug EpisodeScreen
    crumbs =
      PagerViewUtil.buildCrumbs Episodes maybeShow page
  in
    ( crumbs, tabs ++ content )

