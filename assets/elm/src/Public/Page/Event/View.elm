module Page.Event.View exposing (root)

import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import Routing exposing (..)
import PagerViewUtil

root : Model -> String -> String -> ( Crumbs, List (Html Msg) )
root model slug evSlug =
  let
    ( maybeShow, maybeEvents, content ) =
      PagerViewUtil.buildEventList
        model.data slug 0
        { paginate = False, show = Nothing, only = Nothing }
    crumbs =
      PagerViewUtil.buildCrumbs maybeShow 0
  in
    ( crumbs, content )
