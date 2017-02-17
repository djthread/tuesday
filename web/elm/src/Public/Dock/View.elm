module Dock.View exposing (root)

import String exposing (concat)
import Html exposing (Html, div, p, a, text, footer, audio, source)
import Html.Attributes exposing (class, href, style, controls, src, type_, attribute, id)
import Html.Events exposing (onClick)
import Types exposing (..)
import Dock.Types exposing (Track)



root : Model -> Html Msg
root model =
  let
    (display, thesrc, thetitle) =
      case model.dock.track of
        Just track ->
          ("block", track.src, track.title)
        Nothing ->
          ("none", "", "")
  in
    div [class "dock", style [("display", display)]]
      [ div []
          [ audio
              [ --attribute "ref" "audio"
                id "theaudio"
              , attribute "controls" "true"
              -- , attribute "autoplay" "true"
              , attribute "preload" "auto"
              -- , attribute "data-setup" "{}"
              ]
              [ source
                  [ src thesrc
                  , type_ "audio/mp3"
                  ]
                  []
              ]
          , p [] [text (concat ["Now Playing ", thetitle])]
          ]
      ]

ep1url : String
ep1url =
  "https://impulsedetroit.net/download/wobblehead-radio/wobblehead-021.mp3"
