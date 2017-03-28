module Chat.View exposing (root)

import Date exposing (Date)
import Date.Format
import Types exposing (Model, Msg)
import Chat.Types exposing (Msg(..), Line)
import Html exposing (Html, div, text, input, p, span)
import Html.Attributes exposing (class, value, type_, disabled, placeholder, id)
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
          buildMessages lines
        Nothing ->
          [text ""]
  in
    div [ class "chat" ]
      [ div [ class "messages-outer" ]
          [ div
              [ class "messages"
              , id "chat-messages"
              ]
              lines
      ]
      , div [ class "inputs" ]
          [ input
              [ class "name"
              , type_ "text"
              , placeholder "name"
              , value model.chat.name
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


buildMessages : List Line -> List (Html Chat.Types.Msg)
buildMessages lines =
  let
    -- endSplitter =
    --   case List.tail lines of
    --     Nothing -> []
    --     Just line ->
    --       case formatter line.stamp == formatter Date.now of
    --         True  -> []
    --         False -> [daySplitter Date.now]
    lineHtmls =
      List.foldl expander ("", []) lines
        |> Tuple.second
  in
    -- lineHtmls ++ endSplitter
    lineHtmls


expander : Line
        -> ( String, List (Html Chat.Types.Msg) )
        -> ( String, List (Html Chat.Types.Msg) )
expander line ( lastDate, accList ) =
  let
    thisDate =
      formatter line.stamp
    splitter =
      case thisDate == lastDate of
        True  -> []
        False -> [daySplitter line.stamp]
    htmlList =
      accList
      ++ splitter
      ++ [buildLine line]
  in
    ( thisDate, htmlList )


daySplitter : Date -> Html Chat.Types.Msg
daySplitter date =
  let
    str = Date.Format.format "%A, %b %d" date
  in
    div [ class "splitter" ] [ text str ]


buildLine : Line -> Html Chat.Types.Msg
buildLine line =
  let
    stamp =
      Date.Format.format "%l:%M%P" line.stamp
  in
    div [ class "line"]
      [ span [ class "stamp" ]
          [ text stamp ]
      , span [ class "user" ]
          [ text line.user ]
      , span [ class "content" ]
          [ text line.body ]
      ]


formatter : Date -> String
formatter =
  Date.Format.format "%Y%m%d"
