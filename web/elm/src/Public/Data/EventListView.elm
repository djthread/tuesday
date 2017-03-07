module Data.EventListView exposing (root)

import Html exposing (Html, div, span, text, h3, p, table, tr, td)
import Html.Attributes exposing (class, colspan)
import Types exposing (Msg)
import Data.Types exposing (Show, Event, Performance, EventListing, ListConfig)
import TypeUtil exposing (RemoteData, RemoteData(..))
import ViewUtil exposing (waiting, formatDate)
import Routing
import Markdown

root : ListConfig -> RemoteData (List Show) -> RemoteData EventListing
    -> List (Html Msg)
root conf rdShows rdEvents =
  let
    content =
      case rdShows of
        Loaded shows ->
          case rdEvents of
            Loaded lsEvents ->
              let
                pager =
                  if conf.paginate
                      && lsEvents.pager.totalPages > 1
                      then
                        ViewUtil.paginator
                          Routing.eventsPageUrl
                          lsEvents.pager
                    else []
                entries = 
                  case conf.only of
                    Nothing -> lsEvents.entries
                    Just n  -> List.take n lsEvents.entries
              in
                pager
                ++ List.map (buildEvent shows) entries
                ++ pager
            _ -> 
              [ div [] [ text "no events" ] ]
        _ ->
          [ waiting ]
  in
    [ div [ class "event-list" ] content ]


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
      formatDate event.happens_on
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
    , div [ class "colorbox" ]
      [ p [ class "showname" ] [ text show.name ]
      , p [ class "stamp" ] [ text happens_on ]
      ]
    ]
    ++ description
    ++ performances
    ++ [ p [ class "clearer" ] [] ]

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
