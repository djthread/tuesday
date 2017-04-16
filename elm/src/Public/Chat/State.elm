module Chat.State exposing (init, update, subscriptions)

import Types exposing (wsUrl)
import Chat.Types exposing (..)
import Chat.Codec exposing (newMsgDecoder)
import Port
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
import Dom.Scroll
import Task
import StateUtil exposing (pushMessage)
import Phoenix.Push as Push


init : ( Model, Cmd Types.Msg )
init =
  ( { nick  = ""
    , msg   = ""
    , lines = Nothing
    }
  , Port.getChatNick "fo srs"
  )


update : Msg -> Model
      -> ( Model, Cmd Types.Msg )
update msg model =
  case msg of
    ReceiveNewMsg raw ->
      case decodeValue newMsgDecoder raw of
        Ok line ->
          let
            lines =
              case model.lines of
                Just lines -> Just (lines ++ [line])
                Nothing ->    Just [line]
            toBottom =
              Dom.Scroll.toBottom "chat-messages"
          in
            ( { model | lines = lines }
            , Task.attempt (\_ -> Types.NoOp) toBottom
            )

        Err error ->
          ( model, Cmd.none )

    InputNick nick ->
      ( { model | nick = nick }
      , Cmd.none
      )

    InputMsg msg ->
      ( { model | msg = msg }
      , Cmd.none
      )

    OnKeyPress int ->
      case int of
        13 ->   -- enter key
          pushChatMessage model

        _ ->
          ( model, Cmd.none )

    GotChatNick nick ->
      ( { model | nick = nick }
      , Cmd.none
      )

    NoOp ->
      ( model, Cmd.none )


subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Port.gotChatNick GotChatNick


pushChatMessage : Model
               -> ( Model, Cmd Types.Msg )
pushChatMessage model =
  let
    payload =
      JE.object
        [ ( "nick", JE.string model.nick )
        , ( "body", JE.string model.msg )
        ]
    configurator =
      (\p -> p |> Push.withPayload payload)
    cmd =
      pushMessage "new:msg" "rooms:lobby" configurator
    setChatNick =
      Port.setChatNick model.nick
  in
    ( { model | msg = "" }
    , Cmd.batch [cmd, setChatNick]
    )
