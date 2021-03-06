module Page.Episodes.View exposing (root)

import Html exposing (Html)
import Types exposing (..)
import PagerViewUtil

root : Model -> Int -> ( Crumbs, List (Html Msg) )
root model page =
  let
    ( maybeShow, _, content ) =
      PagerViewUtil.buildEpisodeList
        model.data model.player "" page
        { paginate = True
        , show = Nothing
        , only = Nothing
        , linkTitle = True
        }
    crumbs =
      PagerViewUtil.buildCrumbs Episodes maybeShow page
  in
    ( crumbs, content )
