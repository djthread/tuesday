module StateUtil exposing (initSocket, pushMessage, handlePhoenixMsg)

import Types exposing (..)
import Chat.Types
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push

initSocket : ( (Phoenix.Socket.Socket Types.Msg), Cmd Types.Msg )
initSocket =
  let
    initSocket =
      Phoenix.Socket.init "ws://localhost:4091/socket/websocket"
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:lobby"
            (\m -> ChatMsg (Chat.Types.ReceiveNewMsg m))
    channel =
      Phoenix.Channel.init "rooms:lobby"
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.join channel initSocket
  in
    ( phxSocket
    , Cmd.map PhoenixMsg phxCmd )


handlePhoenixMsg : (Phoenix.Socket.Msg Types.Msg) -> IDSocket
                -> ( IDSocket, Cmd Types.Msg )
handlePhoenixMsg msg idSocket =
  let
    ( newSocket, phxCmd ) =
      Phoenix.Socket.update msg idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )


pushMessage : String -> String -> JE.Value -> IDSocket
           -> ( IDSocket, Cmd Types.Msg )
pushMessage message channel payload idSocket =
  let
    push_ =
      Phoenix.Push.init message channel
        |> Phoenix.Push.withPayload payload
    ( newSocket, phxCmd ) =
      Phoenix.Socket.push push_ idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )
