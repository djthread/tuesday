module Data.EpisodeListView exposing (root)

import Html exposing (Html, div, span, text, h3, h4, h6, p, div, button, a, i)
import Html.Attributes exposing (class, href, attribute)
import Types exposing (Msg, Msg(PlayEpisode), PlayerModel)
import Data.Types exposing (Episode, Show)
import TypeUtil exposing (RemoteData, RemoteData(..))
import ViewUtil exposing (waiting, formatDate, myOnClick)
-- import StateUtil exposing (filterLoaded)
import Markdown

root : PlayerModel -> RemoteData (List Show) -> RemoteData (List Episode)
    -> List (Html Msg)
root playerModel rdShows rdEpisodes =
  let
    content =
      case rdShows of
        Loaded shows ->
          case rdEpisodes of
            Loaded episodes ->
              List.map (buildEpisode playerModel shows) episodes
            _ -> 
              [ div [] [ text "no episodes" ] ]
        _ ->
          [ waiting ]
  in
    [ div [ class "episode-list" ] content ]


buildEpisode : PlayerModel -> List Show -> Episode -> Html Msg
buildEpisode playerModel shows episode =
  let
    maybeShow =
      Data.Types.findShow shows episode.show_id
    content =
      case maybeShow of
        Nothing ->
          [ text "Sumn broke.." ]

        Just show ->
          actuallyBuildEpisode playerModel show episode
  in
    div [ class "episode" ] content


actuallyBuildEpisode : PlayerModel -> Show -> Episode -> List (Html Msg)
actuallyBuildEpisode playerModel show episode =
  let
    description =
      if not (String.isEmpty episode.description) then
        [ div [ class "desc" ]
            [ Markdown.toHtml [ class "description" ] episode.description ]
        ]
      else
        []
    stamp =
      "Recorded on "
        ++ (formatDate episode.record_date)
        ++ ". Posted on "
        ++ (formatDate episode.posted_on)
        ++ "."
    epUrl =
      "/download/" ++ show.slug ++ "/" ++ episode.filename
    active =
      case playerModel.track of
        Nothing -> ""
        Just track ->
          if track.src == epUrl then " active" else ""
  in
    [ h3 [ class "title" ]
        [ span [ class "num" ]
            [ text (toString episode.number ++ ". ")
            ]
        , a [ href "#" ] [ text episode.title ]
        ]
    , div [ class "colorbox" ]
        [ p [ class "showname" ]
            [ text show.name ]
        ]
    ]
    ++ description
    ++
    [ div [ class "btn-group btn-group-block" ]
        [ a [ class ("btn btn-sm" ++ active)
            , myOnClick (PlayEpisode epUrl episode.filename)
            ]
            [ i [ class "fa fa-play-circle"
                , attribute "aria-hidden" "true"
                ] []
            , text " Listen"
            ]
        , a [ class "btn btn-sm", href epUrl ]
            [ i [ class "fa fa-download"
                , attribute "aria-hidden" "true"
                ] []
            , text " Download"
            ]
        ]
    , p [ class "stamp" ] [ text stamp ]
    ]
