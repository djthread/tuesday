module Dock.View exposing (root)

import String exposing (concat)
import Html exposing (Html, div, p, a, text, footer, audio, source)
import Html.Attributes exposing (class, href, style, controls, src, type_, attribute)
import Html.Events exposing (onClick)
import Types exposing (..)
import Dock.Types exposing (Track)


root : Model -> Html Msg
root model =
  case model.dock.track of
    Just track ->
      build track

    Nothing ->
      text ""


build : Track -> Html Msg
build track =
  div [class "dock"]
    [ div []
        [ audio
            [ attribute "ref" "audio"
            , controls True
            -- , attribute "data-setup" "{}"
            ]
            [ source
                [ src track.src
                , type_ "audio/mp3"
                ]
                []
            ]
        , p [] [text (concat ["Now Playing ", track.title])]
        ]
    ]

ep1url : String
ep1url =
  "https://impulsedetroit.net/download/wobblehead-radio/wobblehead-021.mp3"
