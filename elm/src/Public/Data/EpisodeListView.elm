module Data.EpisodeListView exposing (root)

import Html exposing (Html, div, span, text, h3, h4, h6, p, div, button, a)
import Html.Attributes exposing (class, href, attribute)
import Types exposing (Msg, Msg(PlayEpisode), PlayerModel)
import Data.Types exposing (Show, Episode, EpisodeListing, ListConfig)
import TypeUtil exposing (RemoteData, RemoteData(..), Pager)
import ViewUtil exposing (waiting)
-- import StateUtil exposing (filterLoaded)
import Routing
import Markdown

root : PlayerModel -> ListConfig
    -> List Show -> EpisodeListing
    -> List (Html Msg)
root playerModel conf shows listing =
  let
    pager =
      if conf.paginate && listing.pager.totalPages > 1 then
        ViewUtil.paginator
          (Routing.maybeShowEpisodesUrl conf.show)
          listing.pager
      else []
    content =
      let
        entries = 
          case conf.only of
            Nothing -> listing.entries
            Just n  -> List.take n listing.entries
        episodeBuilder =
          buildEpisode conf.linkTitle playerModel shows
      in
        if List.length(entries) > 0 then
          List.map episodeBuilder entries
          ++ pager
        else
          [ div [] [ text "no episodes" ] ]
  in
    [ div [ class "episode-list" ] content ]


buildEpisode : Bool -> PlayerModel -> List Show -> Episode
            -> Html Msg
buildEpisode linkTitle playerModel shows episode =
  let
    show =
      Data.Types.findShow shows episode.show_id
    content =
      case show of
        Just s  ->
          actuallyBuildEpisode
            linkTitle playerModel s episode
        Nothing ->
          []
  in
    div [ class "episode" ] content


actuallyBuildEpisode : Bool -> PlayerModel -> Show -> Episode
                    -> List (Html Msg)
actuallyBuildEpisode linkTitle playerModel show episode =
  let
    description =
      if not (String.isEmpty episode.description) then
        [ Markdown.toHtml [ class "desc" ] episode.description ]
      else
        []
    stamp =
      "Recorded on "
        ++ (ViewUtil.formatDate episode.record_date)
        ++ ". Posted on "
        ++ (ViewUtil.formatDate episode.posted_on)
        ++ "."
    epUrl =
      "/download/" ++ show.slug ++ "/" ++ episode.filename
    active =
      case playerModel.track of
        Nothing -> ""
        Just track ->
          if track.src == epUrl then " active" else ""
    titleContent =
      let
        num =
          [ span [ class "num" ]
              [ text (toString episode.number ++ ". ") ]
          ]
        title =
          [ text episode.title ]
        anchor =
          [ a [ href (Routing.episodeUrl show episode) ] title ]
      in
        case linkTitle of
          True  -> num ++ anchor
          False -> num ++ title
  in
    [ h3 [ class "title" ] titleContent
    , div [ class "colorbox" ]
        [ p [ class "showname" ]
            [ text show.name ]
        ]
    ]
    ++ description
    ++
    [ div [ class "btn-group btn-group-block" ]
        [ a [ class ("btn btn-sm" ++ active)
            , ViewUtil.myOnClick (PlayEpisode epUrl episode)
            ]
            [ ViewUtil.fa "play-circle"
            , text " Listen"
            ]
        , a [ class "btn btn-sm", href epUrl ]
            [ ViewUtil.fa "download"
            , text " Download"
            ]
        ]
    , p [ class "stamp" ] [ text stamp ]
    ]
