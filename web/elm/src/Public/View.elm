module View exposing (root)

import Html exposing (Html, text, p)
import Types exposing (..)

root : Model -> Html Msg
root model =
  p [] [text "whaddup"]
