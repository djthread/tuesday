module Page.Events.View exposing (root)

import Data.EventListView
import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import Layout

root : Model -> Html Msg
root model =
  let
    conf =
      { paginate = True, only = Nothing }
    listing =
      Data.EventListView.root
        conf
        model.data.shows
        model.data.events
    pagetext =
      case model.data.events of
        Loaded data ->
          ", Page " ++ (toString data.pager.pageNumber)
        _ ->
          ""
    titletext = 
      "Events" ++ pagetext
    title =
      [ h2 [] [ text titletext ] ]
    crumbs =
      ViewUtil.breadcrumber [("Events", "#events")]
    content =
      div [ class "page-events" ] (title ++ crumbs ++ listing)
  in
    Layout.root model content
