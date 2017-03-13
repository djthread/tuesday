module Page.Episode.View exposing (root)

import Html exposing (Html)
import Types exposing (..)
import PagerViewUtil
import Routing exposing (..)


root : Model -> String -> String -> ( Crumbs, List (Html Msg) )
root model slug epSlug =
  let
    ( maybeShow, maybeEpisodes, content ) =
      PagerViewUtil.buildEpisodeList
        model.data model.player slug 0
        { paginate = False, show = Nothing, only = Nothing }
    crumbs =
      PagerViewUtil.buildCrumbs maybeShow 0
  in
    ( crumbs, content )
