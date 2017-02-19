module Chat.View exposing (root)

import Date.Format
import Types exposing (Model, Msg)
import Chat.Types exposing (Msg(..), Line)
import Html exposing (Html, div, text, input, p)
import Html.Attributes exposing (class, value, type_, disabled, placeholder)
-- import Html.Events exposing (onInput, onClick)
import Html.Events exposing (on, onInput, keyCode)
import Json.Decode as JD


root : Model -> Html Chat.Types.Msg
root model =
  let
    cantSay =
      case model.chat.name of
        "" -> True
        _  -> False
    lines =
      case model.chat.lines of
        Just lines ->
          List.map buildLine lines
        Nothing ->
          [text ""]
  in
    div [class "chat"]
      [ div [class "messages-outer"]
          [ div [class "messages"] lines
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
              , value model.chat.msg
              , onInput InputMsg
              , on "keypress"
                  (JD.map OnKeyPress keyCode)
              ]
              []
          , input
              [ type_ "submit"
              -- , onClick Shout
              , class "submit"
              ]
              []
          ]
      ]

buildLine : Line -> Html Chat.Types.Msg
buildLine line =
  let
    stamp =
      Date.Format.format "%l:%M%P" line.stamp
  in
    div []
      [ p []
          [ text (String.concat
              [ stamp
              , " "
              , line.user
              , ": "
              , line.body
              ])
          ]
      ]
