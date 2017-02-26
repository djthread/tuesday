module Layout exposing (root)

import Html exposing (Html, Attribute,
  div, a, p, text, footer, span, ul, li, h1, header, section, i, button, source, audio)
import Html.Attributes exposing (class, href, attribute, title, style, src, type_, id)
-- import Html.Events exposing (onClick)
import Types exposing (..)
import ViewUtil exposing (toggle)
import String exposing (concat)
-- import Routing exposing (Route(..))
-- import Page.Home.View
-- import Page.About.View
-- import Page.NotFound.View


root : Model -> Html Msg -> Html Msg
root model msg =
  div []
    [ myheader model
    , div []
        [ msg
        , div [ class "modal-footer" ]
            []
            -- [ button [ class "btn btn-link" ]
            --     [ text "Close" ]
            -- , button [ class "btn btn-primary" ]
            --     [ text "Share" ]
            -- ]
        ]
    , player model
    ]

myheader : Model -> Html Msg
myheader model =
  header [class "navbar"]
    [ section [ class "navbar-section" ]
        [ div [ class "loading", toggle False] []
        -- [ div [ class "loading", toggle (model.loading != 0) ] []
        , a [ href "#", class "navbar-brand" ]
            [ span [ class "idi" ] [ text "I" ]
            , text "mpulse Detroit"
            ]
        , a [ href "#shows", class "btn btn-link" ]
            [ text "Shows" ]
        , a [ href "#schedule", class "btn btn-link" ]
            [ text "Schedule" ]
        , a [ href "#podcast", class "btn btn-link" ]
            [ text "Podcast" ]
        , a [ href "#info", class "btn btn-link" ]
            [ text "Info" ]
        , a [ href "//photos.impulsedetroit.net"
            , class "btn btn-link"
            ]
            [text "Photos"]
        ]
    ]

player : Model -> Html Msg
player model =
  let
    (display, thesrc, thetitle) =
      case model.player.track of
        Just track ->
          ("block", track.src, track.title)
        Nothing ->
          ("none", "", "")
  in
    div [class "dock", style [("display", display)]]
      [ p [] [text (concat ["Now Playing ", thetitle])]
      , audio
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
      ]
