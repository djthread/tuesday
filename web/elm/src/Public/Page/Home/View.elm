module Page.Home.View exposing (root)

import Html exposing (Html, Attribute, div, a, p, text, footer, video, source, br, node, section)
import Html.Attributes exposing (class, href, id, controls, preload, poster, src, type_)
import Types exposing (..)
import Chat.View
import ViewUtil exposing (myOnClick)
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

infotext : String
infotext =
  "Impulse Detroit is a ring of recurring DJ events around the city. Tune in live for the video, or subscribe and listen to the podcasts."


build : Model -> Html Msg
build model =
  div []
    [ section [ class "hero" ]
        [ div [class "hero-overlay"]
            [ div [ class "hero-info" ] [ text infotext ]
            ]
        ]
    , div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column col-6" ]
              [ thevideo model
              , div [] [ text "yayy" ]
              , div [] [ text "yayy" ]
              , div []
                  [ a [ myOnClick (PlayEpisode "https://impulsedetroit.net/download/techno-tuesday/techtues-103.mp3" "TT 103"), href "#" ] [ text "TT103" ]
                  , br [] []
                  , br [] []
                  , a [ myOnClick (PlayEpisode "https://impulsedetroit.net/download/techno-tuesday/techtues-102.mp3" "TT 102"), href "#" ] [ text "TT102" ]
                  ]
              , div [] [ text "yayy" ]
              , div [] [ text "yayy" ]
              , div [] [ text "yayy" ]
            ]
            , div [ class "column col-6" ]
                -- [ Html.map ChatMsg (Chat.View.root model.chat)
                [ Html.map ChatMsg (Chat.View.root model)
                ]
            ]
        ]
    ]


thevideo : Model -> Html Msg
thevideo model =
  case model.video of
    False ->
      div []
        [ a [ myOnClick EnableVideo, href "#" ]
            [ text "Start video" ]
        ]
    True ->
      -- div [class "video-responsive"]
      div []
        [ node "script" [src "//vjs.zencdn.net/5.8.8/video.min.js"] []
        , video
            [ id "thevideo"
            , class "video-js vjs-default-skin embed-responsive-item"
            , controls True
            , preload "auto"
            , poster "/images/poster.jpg"
            ]
            [ source [src feedsrc, type_ "rtmp/flv"] [] ]
        ]
