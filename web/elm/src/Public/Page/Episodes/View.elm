module Page.Episodes.View exposing (root)

import Data.EpisodeListView
import Html exposing (Html)
import Types exposing (..)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import PagerViewUtil
import Routing

root : Model -> String -> Int -> ( Crumbs, List (Html Msg) )
root model slug page =
  let
    ( maybeShow, content ) =
      PagerViewUtil.buildEpisodeList
        model.data model.player slug page
        { paginate = True, show = Nothing, only = Nothing }
    crumbs =
      PagerViewUtil.buildCrumbs maybeShow page
  in
    ( crumbs, content )
