module Data.EventsEpisodesColumnsView exposing (root)

import Html exposing (Html, h2, div, text, p, a, form, input)
import Html.Attributes exposing (attribute, class, type_, value, href, src)
import Types exposing (..)
import Data.Types
import Data.EventListView
import Data.EpisodeListView
import TypeUtil exposing (RemoteData(Loaded))
-- import ViewUtil


root : Data.Types.Model -> PlayerModel -> String -> String
    -> List (Html Msg)
root model player moreEventsUrl moreEpisodesUrl =
  let
    _ = model |> Debug.log "MODEL"
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
        Loaded listing -> List.length listing.entries > 5
        _ -> False
  in
    [ div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [ text "Upcoming Events" ]
                  ]
                  ++
                  ( let options =
                      { paginate = False, only = Just 5 }
                    in Data.EventListView.root
                      options model.shows model.events
                  )
                  ++
                  ( if thereAreMore model.events then
                      moreButton "More Events" moreEventsUrl
                    else []
                  )
                )
            , div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [text "Recent Episodes"]
                  ]
                  ++
                  ( let options =
                      { paginate = False, only = Just 5 }
                    in Data.EpisodeListView.root
                      options player model.shows model.episodes
                  )
                  ++
                  ( if thereAreMore model.episodes then
                      moreButton "More Episodes" moreEpisodesUrl
                    else []
                  )
                )
            ]
        ]
    ]
