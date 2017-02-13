module Page.Home.View exposing (..)

import Html exposing (Html, div, a, p, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)

root : Model -> Html Msg
root model =
  div [class "row"]
    [ div [class "large-6 columns"]
      [ text "hello"
      , a [href "#about"] [text "About page"]
      , p [] [text "And so it was, some things and stuff about whatever to make a longer line of text."]
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
