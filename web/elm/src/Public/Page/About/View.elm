module Page.About.View exposing (..)

import Html exposing (Html, div, p, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)

root : Model -> Html Msg
root model =
  div [class "row"]
    [ p [] [text "about!"]
    ]
