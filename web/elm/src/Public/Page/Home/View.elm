module Page.Home.View exposing (root)

import Html exposing (Html, Attribute, div, h2, a, p, i, text, footer, video, source, br, node, section)
import Html.Attributes exposing (class, style, href, id, controls, preload, poster, src, type_)
import Types exposing (..)
import Chat.View
import Data.EventListView
import Data.EpisodeListView
import ViewUtil
import Layout
import Routing


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
        [ div [ class "hero-overlay" ]
            [ div [ class "hero-info" ] [ text infotext ]
            ]
        ]
    , div [ class "container maincontent" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                [ thevideo model
                , div [ class "infobox" ]
                    [ p []
                        [ ViewUtil.fa "music"
                        , text " You can also tune in, audio only, via the "
                        , a [ href "https://impulsedetroit.net/id.pls" ]
                            [ text "MP3 stream" ]
                        , text "!"]
                    -- , p []
                    --     [ ViewUtil.fa "question-circle"
                    --     , text " If you're having trouble, check out our "
                    --     , a [ href "#streaming-tips" ]
                    --         [ text "streaming tips" ]
                    --     , text " page."
                    --     ]
                    ]
                , div [ class "homesocialbtns" ]
                    [ h2 [ style [("padding-top", "1rem")] ] [ text "Follow Us!" ]
                    , ViewUtil.socialButtons
                    ]
                ]
            , div [ class "column col-sm-12 col-6" ]
                [ Html.map ChatMsg (Chat.View.root model)
                ]
            ]
        ]
    , div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [ text "Upcoming Events" ]
                  ]
                  ++
                  ( Data.EventListView.root
                      False model.data.shows model.data.events
                  )
                  ++
                  [ a [ class "morebtn"
                      , href (Routing.eventsPageUrl 2)
                      ]
                      [ text "More Events" ]
                  ]
                )
            , div [ class "column col-sm-12 col-6" ]
                ( [ h2 [] [text "Recent Episodes"]
                  ]
                  ++
                  ( Data.EpisodeListView.root
                      False model.player model.data.shows model.data.episodes
                  )
                  ++
                  [ a [ class "morebtn"
                      , href (Routing.episodesPageUrl 2)
                      ]
                      [ text "More Episodes" ]
                  ]
                )
            ]
        ]
    ]


thevideo : Model -> Html Msg
thevideo model =
  case model.video of
    False ->
      div [ class "video-button" ]
        [ a [ ViewUtil.myOnClick EnableVideo, href "#" ]
            [ ViewUtil.fa "play-circle-o fa-5x" ]
        ]
    True ->
      -- div [class "video-responsive"]
      div []
        -- [ node "script" [ src "//vjs.zencdn.net/5.8.8/video.min.js" ] []
        -- [ node "script" [ src "/js/video.min.js" ] []
        [ video
            [ id "thevideo"
            , class "video-js vjs-default-skin embed-responsive-item"
            , controls True
            , preload "auto"
            , poster "/images/poster.jpg"
            ]
            [ source [src feedsrc, type_ "rtmp/flv"] [] ]
        ]
