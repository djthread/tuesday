module Page.Show.Info.View exposing (root)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Types exposing (..)
import Data.Types exposing (Slug, Show, ShowDetail, findShowBySlug)
import TypeUtil exposing (RemoteData(Loaded))
import Routing exposing (showUrl, showInfoUrl)
import Page.Show.ViewUtil exposing (tabber, ShowScreen(InfoScreen))
import ViewUtil
import Markdown

root : Model -> Slug -> ( Crumbs, List (Html Msg) )
root model slug =
  let
    ( crumbs, content ) =
      case model.data.shows of
        Loaded shows ->
          case model.data.showDetail of
            Loaded detail ->
              case findShowBySlug shows slug of
                Just show ->
                  let
                    crumbs =
                      [ ( show.name, showUrl show.slug )
                      , ( "Info", "" )
                      ]
                  in
                    ( crumbs, build show detail )
                Nothing -> ViewUtil.wait
            _ -> ViewUtil.wait
        _ -> ViewUtil.wait
    tabs =
      tabber slug InfoScreen
  in
    ( crumbs, tabs ++ content )


build : Show -> ShowDetail -> List (Html Msg)
build show detail =
  [ Markdown.toHtml
      [ class "the-show-info"
      ]
      detail.fullInfo
  ]
