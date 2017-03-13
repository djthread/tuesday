module Data.EventsEpisodesColumnsView exposing (root)

import Html exposing (Html, h2, div, text, p, a, form, input)
import Html.Attributes exposing (attribute, class, type_, value, href, src)
import Types exposing (..)
import Data.Types
import Data.EventListView
import Data.EpisodeListView
import TypeUtil exposing (RemoteData(Loaded))
import PagerViewUtil


root : Data.Types.Model -> PlayerModel
    -> String -> String -> String
    -> List (Html Msg)
root model player slug moreEventsUrl moreEpisodesUrl =
  let
    -- _ = model |> Debug.log "MODEL"
    moreButton words url =
      [ form []
          [ input
              [ type_ "button"
              , class "btn morebtn"
              , attribute "onClick"
                  ( "parent.location='"
                      ++ url
                      ++ "'"
                  )
              , value words
              ]
              []
          ]
      ]
    thereAreMore remoteListing =
      case remoteListing of
        Loaded listing ->
          List.length listing.entries > 5
        _ ->
          False
    eventList =
      let
        ( _, _, content ) =
          PagerViewUtil.buildEventList
            model slug 1
            { paginate = False
            , show = Nothing
            , only = Just 5 }
      in
        content
    episodeList =
      let
        ( _, _, content ) =
          PagerViewUtil.buildEpisodeList
            model player slug 1
            { paginate = False
            , show = Nothing
            , only = Just 5 }
      in
        content
  in
    [ div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [ text "Upcoming Events" ] ]
                  ++
                  eventList
                  -- let options =
                  --   { paginate = False, show = Nothing, only = Just 5 }
                  -- in Data.EventListView.root
                  --   options model.shows model.events
                  ++
                  if thereAreMore model.events then
                    moreButton "More Events" moreEventsUrl
                  else []
                )
            , div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [text "Recent Episodes"] ]
                  ++
                  episodeList
                  ++
                  if thereAreMore model.episodes then
                    moreButton "More Episodes" moreEpisodesUrl
                  else []
                )
            ]
        ]
    ]
