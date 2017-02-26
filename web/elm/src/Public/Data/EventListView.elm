module Data.EventListView exposing (root)

import Html exposing (Html, div, span, text, h3, p, table, tr, td)
import Html.Attributes exposing (class, colspan)
import Types exposing (Msg)
import Data.Types exposing (Show, Event, Performance, Episode)
import TypeUtil exposing (RemoteData, RemoteData(..))
-- import StateUtil exposing (filterLoaded)
import Date.Format
import Markdown

root : RemoteData (List Show) -> RemoteData (List Event)
    -> List (Html Msg)
root rdShows rdEvents =
  let
    --   filterLoaded [shows, events]
    fn =
      \shows event -> buildEvent shows event
    waiting =
      [ div [] [ text "..."] ]
    content =
      case rdShows of
        Loaded shows ->
          case rdEvents of
            Loaded events ->
              List.map (buildEvent shows) events
            _ -> 
              [ div [] [ text "no events" ] ]
        _ ->
          waiting
  in
    [ div [ class "eventList" ] content ]


buildEvent : List Show -> Event -> Html Msg
buildEvent shows event =
  let
    maybeShow =
      Data.Types.findShow shows event.show_id
    content =
      case maybeShow of
        Nothing ->
          [ text "Sumn broke.." ]

        Just show ->
          actuallyBuildEvent show event
  in
    div [ class "event" ] content


actuallyBuildEvent : Show -> Event -> List (Html Msg)
actuallyBuildEvent show event =
  let
    happens_on =
      Date.Format.format "%A, %B %d" event.happens_on
    performanceList =
      event.performances
        |> List.map renderPerformance
        |> List.concat
    performances =
      if List.length performanceList > 0 then
        [ table [ class "performances" ] performanceList ]
      else
        []
    description =
      if not (String.isEmpty event.description) then
        [ div [ class "description" ] [ text event.description ] ]
      else
        []
  in
    [ h3 [] [ text event.title ]
    , p [ class ("showname bg-" ++ show.slug) ] [ text show.name ]
    , p [ class ("stamp bg-" ++ show.slug) ] [ text happens_on ]
    ]
    ++ description
    ++ performances

renderPerformance : Performance -> List (Html Msg)
renderPerformance perf =
  let
    extra =
      case perf.extra of
        "" -> []
        _  ->
          [ tr []
              [ td [ colspan 2 ]
                  [ Markdown.toHtml [ class "extra" ] perf.extra ]
              ]
          ]
    hasGenres =
      perf.genres |> String.isEmpty |> not
    hasAffiliations =
      perf.affiliations |> String.isEmpty |> not
    meta =
      let
        string =
          String.concat
            [ "("
            , perf.genres
            , if hasGenres && hasAffiliations then "; " else ""
            , perf.affiliations
            , ")"
            ]
      in
        if hasGenres || hasAffiliations then
          [ text " "
          , span [ class "meta" ] [ text string ]
          ]
        else
          []
  in
    [ tr []
        [ td [ class "time" ] [ text perf.time ]
        , td []
            ( [ span [ class "artist" ] [ text perf.artist ]
              ]
              ++ meta
            )
        ]
    ]
    ++ extra

--
-- type alias Performance =
--   { time         : String
--   , artist       : String
--   , genres       : String
--   , affiliations : String
--   }
--
-- type alias Event =
--   { id           : Int
--   , show_id      : Int
--   , title        : String
--   -- , showslug     : String
--   , happens_on   : Date
--   , description  : String
--   , performances : List Performance
--   }
