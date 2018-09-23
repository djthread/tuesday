module Page.Home.View exposing (root)

import Html exposing (Html, Attribute, div, h2, a, p, i, text,
                        footer, video, source, br, node, section,
                        button, form, input)
import Html.Attributes exposing (class, style, href, id,
                        controls, preload, poster, src, type_,
                        value, attribute)
import Types exposing (..)
import Chat.View
import Data.EventsEpisodesColumnsView
import ViewUtil exposing (fa)
import Photo.WidgetView
import Routing


infotext : String
infotext =
  "Impulse Detroit is a ring of recurring DJ events around the city. "
  ++ "Tune in live for the video, or subscribe and listen to the podcasts."


root : Model -> ( Crumbs, List (Html Msg) )
root model =
  ( [], build model )

build : Model -> List (Html Msg)
build model =
  [ section [ class "hero" ]
      [ div [ class "hero-overlay" ]
          [ div [ class "hero-info" ] [ text infotext ] ]
      ]
  , div [ class "container maincontent" ]
      [ div [ class "columns" ]
          [ div [ class "column col-sm-12 col-6" ]
              [ thevideo model
              , div [ class "infobox" ]
                  [ p []
                      [ fa "music"
                      , text " You can also tune in, audio only, via the "
                      , a [ href "https://impulsedetroit.net/id.pls" ]
                          [ text "MP3 stream" ]
                      , text "!"]
                  -- , p []
                  --     [ fa "question-circle"
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
  ]
  ++ Photo.WidgetView.root model.photo
  ++ Data.EventsEpisodesColumnsView.root model.data model.player ""
      (Routing.eventsUrl 1)
      (Routing.episodesUrl 1)


thevideo : Model -> Html Msg
thevideo model =
  case model.video of
    False ->
      div [ class "video-button" ]
        [ a [ ViewUtil.myOnClick EnableVideo, href "#" ]
            [ fa "play-circle-o fa-5x" ]
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
            []
            -- [ source [type_ "application/x-mpegURL"] [] ]
            -- [ source [src feedsrc, type_ "rtmp/flv"] [] ]
        ]
