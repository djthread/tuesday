module Chat.View exposing (root)

import Types exposing (..)
import Chat.Types exposing (Msg(..))
import Html exposing (Html, div, text, input)
import Html.Attributes exposing (class, value, type_, disabled, placeholder)
import Html.Events exposing (onInput)


root : Types.Model -> Html Types.Msg
root model =
  let
    cantSay =
      case model.chat.name of
        "" -> True
        _  -> False
  in
    div [class "chatapp"]
      [ div [class "chat"]
          [
            text "sap"
          ]
      , div [class "inputs"]
          [ input
              [ class "name"
              , type_ "text"
              , placeholder "name"
              , onInput InputUser
              ]
              []
          , input
              [ class "msg"
              , type_ "text"
              , disabled cantSay
              , onInput InputMsg
              ]
              []
          , input
              [type_ "submit"]
              []
          ]
      ]
