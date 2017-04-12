module Page.Show.Events.View exposing (root)

import Html exposing (Html)
import Types exposing (..)
import PagerViewUtil
import Page.Show.ViewUtil exposing (tabber, ShowScreen(EventScreen))
import TypeUtil exposing (RemoteData(Loaded))

root : Model -> String -> Int -> ( Crumbs, List (Html Msg) )
root model slug page =
  let
    ( maybeShow, _, content ) =
      PagerViewUtil.buildEventList
        model.data slug page
        { paginate = True
        , show = Nothing
        , only = Nothing
        , linkTitle = True
        }
    hasInfo =
      case model.data.showDetail of
        Loaded detail ->
          if String.isEmpty detail.fullInfo then
            False
          else
            True
        _ ->
          False
    tabs =
      tabber slug EventScreen hasInfo
    crumbs =
      PagerViewUtil.buildCrumbs Events maybeShow page
  in
    ( crumbs, tabs ++ content )

