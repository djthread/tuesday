module Page.Events.View exposing (root)

import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import PagerViewUtil

root : Model -> Int
    -> ( Crumbs, List (Html Msg) )
root model page =
  let
    ( maybeShow, _, content ) =
      PagerViewUtil.buildEventList
        model.data "" page
        { paginate = True
        , show = Nothing
        , only = Nothing
        , linkTitle = True
        }
    crumbs =
      PagerViewUtil.buildCrumbs
        Events maybeShow page
  in
    ( crumbs, content )
