module Page.Events.View exposing (root)

import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import PagerViewUtil

root : Model -> String -> Int -> ( Crumbs, List (Html Msg) )
root model slug page =
  let
    ( maybeShow, content ) =
      PagerViewUtil.buildEventList
        model.data slug page
        { paginate = True, show = Nothing, only = Nothing }
    crumbs =
      PagerViewUtil.buildCrumbs maybeShow page
  in
    ( crumbs, content )
