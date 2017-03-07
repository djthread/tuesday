module Page.Episodes.View exposing (root)

import Data.EpisodeListView
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
      Data.EpisodeListView.root
        conf
        model.player
        model.data.shows
        model.data.episodes
    ( page, pagetext ) =
        case model.data.episodes of
          Loaded data ->
            let page = data.pager.pageNumber
            in
              ( page 
              , ", Page " ++ (toString page)
              )
          _ -> ( 1, "" )
    -- titletext = 
    --   "Podcast Episodes" -- ++ pagetext
    -- title =
    --   [ h2 [] [ text titletext ] ]
    crumbs =
      ViewUtil.breadcrumber
        ( if page == 1 then [("Episodes", "")] else
            [ ("Episodes", "#episodes")
            , ("Page " ++ toString page, "")
            ]
        )
    content =
      div [ class "page page-episodes" ] (crumbs ++ listing)
  in
    Layout.root model content
