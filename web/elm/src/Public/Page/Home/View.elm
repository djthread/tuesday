module Page.Home.View exposing (..)

import Html exposing (Html, div, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)

root : Model -> Html Msg
root model =
  div [class "row"]
    [ div [class "column small-6"]
      [ text "hello"
      , a [href "#about"] [text "About page"]
      ]
    , div [class "column small-6"]
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
