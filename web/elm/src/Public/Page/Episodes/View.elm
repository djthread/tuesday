module Page.Episodes.View exposing (root)

import Data.EpisodeListView
import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import TypeUtil exposing (RemoteData(Loaded))
import Layout

root : Model -> Html Msg
root model =
  let
    listing =
      Data.EpisodeListView.root
        True
        model.player
        model.data.shows
        model.data.episodes
    pagetext =
      case model.data.episodes of
        Loaded data ->
          ", Page " ++ (toString data.pager.pageNumber)
        _ ->
          ""
    titletext = 
      "Podcast Episodes" ++ pagetext
    title =
      [ h2 [] [ text titletext ] ]
    content =
      div [ class "page-episodes" ] (title ++ listing)
  in
    Layout.root model content
