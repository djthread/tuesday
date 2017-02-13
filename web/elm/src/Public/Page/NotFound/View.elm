module Page.NotFound.View exposing (..)

import Html exposing (Html, div, p, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)

root : Model -> Html Msg
root model =
  div []
    [ p [] [text "404 not found"]
    ]
