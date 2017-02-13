module Page.Live.View exposing (root)

import Html exposing (Html, div, a, p, text, footer, video, source)
import Html.Attributes exposing (class, href, id, controls, preload, poster, src, type_)
import Html.Events exposing (onClick)
import Types exposing (..)

feedsrc : String
feedsrc =
  "rtmp://impulsedetroit.net/live/techno" 

root : Model -> Html Msg
root model =
  div [class "row"]
    [ div [class "large-6 columns"]
      [ p [] [text "And so it was, some things and stuff about whatever to make a longer line of text."]
      , video
          [ id "thevideo"
          , class "video-js vjs-default-skin embed-responsive-item"
          , controls True
          , preload "auto"
          , poster "/images/poster.jpg"
          ]
          [ source [src feedsrc, type_ "rtmp/flv"] [] ]
      ]
    , div [class "large-6 columns"]
        [ div [] [text "yayy"]
        , div [] [text "yayy"]
        , div [] [text "yayy"]
        , div [] [text "yayy"]
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
