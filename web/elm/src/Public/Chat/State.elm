module Chat.State exposing (update, subscriptions)

import StateUtil exposing (pushMessage)
import Types
import Chat.Types exposing (..)
import Chat.Modem exposing (newMsgDecoder)
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
import Time exposing (Time)
import Navigation exposing (Location)
import Dom.Scroll
import Task


update : Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
  case msg of
    ReceiveNewMsg raw ->
      case decodeValue newMsgDecoder raw of
        Ok line ->
          let
            chat =
              model.chat
            lines =
              case chat.lines of
                Just lines -> Just (lines ++ [line])
                Nothing ->    Just [line]
            toBottom =
              Dom.Scroll.toBottom "chat-messages"
          in
            ( { model
              | chat = { chat | lines = lines }
              }
            , Task.attempt (\_ -> Types.NoOp) toBottom
            )

        Err error ->
          ( model, Cmd.none )

    InputUser name ->
      let
        chat = model.chat
      in
        ( { model | chat = { chat | name = name } }
        , Cmd.none
        )

    InputMsg msg ->
      let
        chat = model.chat
      in
        ( { model | chat = { chat | msg = msg } }
        , Cmd.none
        )

    Shout ->
      pushChatMessage model

    OnKeyPress int ->
      case int of
        13 ->   -- enter key
          pushChatMessage model

        _ ->
          ( model, Cmd.none )

    NoOp ->
      ( model, Cmd.none )



subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
  Sub.none



pushChatMessage : Types.Model
               -> ( Types.Model, Cmd Types.Msg )
pushChatMessage model =
  let
    payload =
      JE.object
        [ ( "user", JE.string model.chat.name )
        , ( "body", JE.string model.chat.msg )
        ]
    ( model_, cmd ) =
      pushMessage "new:msg" "rooms:lobby" payload model
    chat =
      model_.chat
  in
    ( { model_ | chat = { chat | msg = "" } }
    , cmd
    )
