module Layout exposing (root)

import Html exposing (Html, Attribute,
  div, a, p, text, footer, span, ul, li, h1, header, section, i, button, source, audio, sup)
import Html.Attributes exposing (class, href, attribute, title, style, src, type_, id, target)
-- import Html.Events exposing (onClick)
import Types exposing (..)
import ViewUtil exposing (fa)
-- import String exposing (concat)
-- import Routing exposing (Route(..))
-- import Page.Home.View
-- import Page.About.View
-- import Page.NotFound.View


root : Model -> Html Msg -> Html Msg
root model content =
  div []
    [ myheader model
    , div []
        [ content
        , footer [ class "container" ]
            [ div [ class "columns" ]
                [ div [ class "column col-sm-12 col-4" ]
                    footerColumn1
                , div [ class "column col-sm-12 col-4" ]
                    footerColumn2
                , div [ class "column col-sm-12 col-4" ]
                    [ p [] [ text "Follow Us On" ]
                    , ViewUtil.socialButtons
                    ]
                , div [ class "shmegal" ] shmegal
                ]
            ]
        ]
    , player model
    ]

shmegal : List (Html Msg)
shmegal =
  [ p [] [ fa "copyright" ]
  , text " 2017 Impulse Detroit"
  ]

myheader : Model -> Html Msg
myheader model =
  header [ class "navbar" ]
    [ section [ class "navbar-section" ]
        [ div [ class "loading", ViewUtil.toggle False] []
        -- [ div [ class "loading", toggle (model.loading != 0) ] []
        , a [ href "#", class "navbar-brand" ]
            [ span [ class "idi" ] [ text "I" ]
            , text "mpulse Detroit"
            ]
        , a [ href "#shows", class "btn btn-link" ]
            [ text "Shows" ]
        -- , a [ href "#schedule", class "btn btn-link" ]
        --     [ text "Schedule" ]
        -- , a [ href "#podcast", class "btn btn-link" ]
        --     [ text "Podcast" ]
        , a [ href "#about", class "btn btn-link" ]
            [ text "About" ]
        , a [ href "//photos.impulsedetroit.net"
            , class "btn btn-link"
            , target "_blank"
            ]
            [ text "Photos"
            , sup [ class "ext" ] [ fa "external-link" ]
            ]
        ]
    ]

footerColumn1 : List (Html Msg)
footerColumn1 =
  [ p [] [ text "Made possible by" ]
  , ul []
      [ li []
          [ a [ href "https://github.com/arut/nginx-rtmp-module" ]
              [ text "nginx-rtmp-module" ]
          , text ", "
          , a [ href "http://nginx.org/nginx" ]
              [ text "nginx" ]
          ]
      , li []
          [ a [ href "http://www.phoenixframework.org/" ]
              [ text "Phoenix" ]
          , text ", "
          , a [ href "http://elixir-lang.org/" ]
              [ text "Elixir" ]
          ]
      , li []
          [ a [ href "http://elm-lang.org" ] [ text "Elm" ]
          , text ", "
          , a [ href "http://videojs.com/" ] [ text "Video.js" ]
          ]
      ]
  ]


footerColumn2 : List (Html Msg)
footerColumn2 =
  [ p [] [ text "Special thanks to" ]
  , ul []
      [ li [] [ a [ href "http://www.urbanbeanco.com/" ] [ text "Urban Bean Co." ] ]
      , li [] [ a [ href "https://rocketfiber.com/" ] [ text "Rocket Fiber" ] ]
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
    div [ class "dock", style [("display", display)] ]
      [ div [ class "close" ]
          [ a [ ViewUtil.myOnClick ClosePlayer ]
              [ fa "window-close-o" ]
          ]
      , p []
          [ text "Now Playing "
          , span [] [ text thetitle ]
          ]
      , audio
          [ --attribute "ref" "audio"
            id "theaudio"
          -- , attribute "controls" "true"
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
