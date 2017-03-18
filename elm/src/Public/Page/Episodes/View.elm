module Page.Episodes.View exposing (root)

import Html exposing (Html)
import Types exposing (..)
import PagerViewUtil

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
    crumbs =
      PagerViewUtil.buildCrumbs Episodes maybeShow page
  in
    ( crumbs, content )
