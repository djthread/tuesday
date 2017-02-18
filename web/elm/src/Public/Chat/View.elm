module Chat.View exposing (root)

import Types exposing (..)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)

root : Model -> Html Msg
root model =
  div [class "chat"]
    [
      text "sap"
    ]
