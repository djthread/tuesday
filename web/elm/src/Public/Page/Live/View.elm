module Page.Live.View exposing (root)

import Html exposing (Html, div, a, p, text, footer, video, source, br, node)
import Html.Attributes exposing (class, href, id, controls, preload, poster, src, type_)
import Html.Events exposing (onClick)
import Types exposing (..)
import Layout


root : Model -> Html Msg
root model =
  let
    page = build model
  in
    Layout.root model page


feedsrc : String
feedsrc =
  "rtmp://impulsedetroit.net/live/techno" 


build : Model -> Html Msg
build model =
  div [class "container"]
    [ div [class "columns"]
        [ div [class "column col-6"]
          [ p [] [text "And so it was, some things and stuff about whatever to make a longer line of text."]
          , node "script" [src "//vjs.zencdn.net/5.8.8/video.min.js"] []
          , video
              [ id "thevideo"
              , class "video-js vjs-default-skin embed-responsive-item"
              , controls True
              , preload "auto"
              , poster "/images/poster.jpg"
              ]
              [ source [src feedsrc, type_ "rtmp/flv"] [] ]
          ]
        , div [class "column col-6"]
            [ div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div []
                [ a [onClick (PlayPodcast "https://impulsedetroit.net/download/techno-tuesday/techtues-103.mp3" "TT 103"), href "#"] [text "TT103"]
                , br [] []
                , br [] []
                , a [onClick (PlayPodcast "https://impulsedetroit.net/download/techno-tuesday/techtues-102.mp3" "TT 102"), href "#"] [text "TT102"]
                ]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            , div [] [text "yayy"]
            ]
        ]
    ]
