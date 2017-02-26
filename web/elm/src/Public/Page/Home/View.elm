module Page.Home.View exposing (root)

import Html exposing (Html, Attribute, div, h2, a, p, i, text, footer, video, source, br, node, section)
import Html.Attributes exposing (class, href, id, controls, preload, poster, src, type_)
import Types exposing (..)
import Chat.View
import Data.EventListView
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
    , div [ class "container maincontent" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                [ thevideo model
                , div [] [ p [] [ text "Welcome to Impulse Detroit!" ] ]
                    -- [ a [ myOnClick (PlayEpisode "https://impulsedetroit.net/download/techno-tuesday/techtues-103.mp3" "TT 103"), href "#" ] [ text "TT103" ]
                ]
            , div [ class "column col-sm-12 col-6" ]
                [ Html.map ChatMsg (Chat.View.root model)
                ]
            ]
        ]
    , div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [text "Upcoming Events"]
                  ]
                  ++ Data.EventListView.root
                      model.data.shows model.data.upcomingEvents
                )
            , div [ class "column col-sm-12 col-6" ]
                [ h2 [] [text "Recent Episodes"]
                -- , EpisodeList.View.root model.shows model.recentEpisodes
                ]
            ]
        ]
    ]


thevideo : Model -> Html Msg
thevideo model =
  case model.video of
    False ->
      div [ class "video-button" ]
        [ a [ myOnClick EnableVideo, href "#" ]
            [ i [ class "fa fa-play-circle-o fa-5x" ] []
            ]
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
