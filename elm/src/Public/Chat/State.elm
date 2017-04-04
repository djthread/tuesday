module Chat.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Chat.Types exposing (..)
import Chat.Codec exposing (newMsgDecoder)
import Port
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
import Dom.Scroll
import Task
import StateUtil exposing (pushMessage)
import Phoenix.Push


init : ( Model, Cmd Types.Msg )
init =
  ( { name  = ""
    , msg   = ""
    , lines = Nothing
    }
  , Port.getChatName "fo srs"
  )


update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
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
            , idSocket
            )

        Err error ->
          ( model, Cmd.none, idSocket )

    InputUser name ->
      ( { model | name = name }
      , Cmd.none
      , idSocket
      )

    InputMsg msg ->
      ( { model | msg = msg }
      , Cmd.none
      , idSocket
      )

    OnKeyPress int ->
      case int of
        13 ->   -- enter key
          pushChatMessage model idSocket

        _ ->
          ( model, Cmd.none, idSocket )

    GotChatName name ->
      ( { model | name = name }
      , Cmd.none
      , idSocket
      )

    NoOp ->
      ( model, Cmd.none, idSocket )


subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Port.gotChatName GotChatName


pushChatMessage : Model -> IDSocket
               -> ( Model, Cmd Types.Msg, IDSocket )
pushChatMessage model idSocket =
  let
    payload =
      JE.object
        [ ( "user", JE.string model.name )
        , ( "body", JE.string model.msg )
        ]
    configurator =
      (\p -> p |> Phoenix.Push.withPayload payload)
    ( newSocket, cmd ) =
      pushMessage "new:msg" "rooms:lobby" configurator idSocket
    setChatName =
      Port.setChatName model.name
  in
    ( { model | msg = "" }
    , Cmd.batch [cmd, setChatName]
    , newSocket
    )
