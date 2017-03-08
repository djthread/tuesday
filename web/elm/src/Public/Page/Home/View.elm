module Page.Home.View exposing (root)

import Html exposing (Html, Attribute, div, h2, a, p, i, text, footer, video, source, br, node, section, button, form, input)
import Html.Attributes exposing (class, style, href, id, controls, preload, poster, src, type_, value, attribute)
import Types exposing (..)
import Chat.View
import Data.EventListView
import Data.EpisodeListView
import ViewUtil exposing (fa)
import Routing


feedsrc : String
feedsrc =
  "rtmp://impulsedetroit.net/live/techno" 

infotext : String
infotext =
  "Impulse Detroit is a ring of recurring DJ events around the city. Tune in live for the video, or subscribe and listen to the podcasts."


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
  , div [ id "photo-widget", class "photo-widget" ]
      [ div [ id "photo-feed" ] []
      , p [ class "photo-more" ]
          [ a [ id "photo-more-link", href "#" ]
              [ text "Load Next Four" ]
          , fa "long-arrow-right"
          ]
      , p [ class "clearer" ] []
      ]
  , div [ class "container" ]
      [ div [ class "columns" ]
          [ div [ class "column col-sm-12 col-6" ]
              ( [ h2 [] [ text "Upcoming Events" ]
                ]
                ++
                ( let options =
                    { paginate = False, only = Just 5 }
                  in Data.EventListView.root
                    options model.data.shows model.data.events
                )
                ++
                [ form []
                    [ input
                        [ type_ "button"
                        , class "btn morebtn"
                        , attribute "onClick"
                            ( "parent.location='"
                                ++ (Routing.eventsPageUrl 1)
                                ++ "'"
                            )
                        , value "More Events"
                        ]
                        []
                    ]
                ]
              )
          , div [ class "column col-sm-12 col-6" ]
              ( [ h2 [] [text "Recent Episodes"]
                ]
                ++
                ( let options =
                    { paginate = False, only = Just 5 }
                  in Data.EpisodeListView.root
                    options model.player model.data.shows model.data.episodes
                )
                ++
                [ form []
                    [ input
                        [ type_ "button"
                        , class "btn morebtn"
                        , attribute "onClick"
                            ( "parent.location='"
                                ++ (Routing.episodesPageUrl 1)
                                ++ "'"
                            )
                        , value "More Episodes"
                        ]
                        []
                    ]
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
            [ source [src feedsrc, type_ "rtmp/flv"] [] ]
        ]
