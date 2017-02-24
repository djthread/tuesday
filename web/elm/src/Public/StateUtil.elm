module StateUtil exposing (initSocket, pushMessage, handlePhoenixMsg)

import Types exposing (..)
import Chat.Types
import Data.Types
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push

wsUrl : String
wsUrl =
  "wss://api.impulsedetroit.net/socket/websocket"
  -- "ws://localhost:4091/socket/websocket"

initSocket : ( (Phoenix.Socket.Socket Types.Msg), Cmd Types.Msg )
initSocket =
  let
    initSocket =
      wsUrl
        |> Phoenix.Socket.init
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:lobby"
            (\m -> ChatMsg (Chat.Types.ReceiveNewMsg m))
        |> Phoenix.Socket.on "shows" "site"
            (\m -> DataMsg (Data.Types.ReceiveShows m))
    channel =
      Phoenix.Channel.init "rooms:lobby"
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.join channel initSocket
    onJoin =
      always SocketInitialized
    channel2 =
      Phoenix.Channel.init "site"
        |> Phoenix.Channel.onJoin onJoin
    ( phxSocket2, phxCmd2 ) =
      Phoenix.Socket.join channel2 phxSocket
    cmd =
      Cmd.batch
        [ Cmd.map PhoenixMsg phxCmd
        , Cmd.map PhoenixMsg phxCmd2
        ]
  in
    ( phxSocket2, cmd )


handlePhoenixMsg : (Phoenix.Socket.Msg Types.Msg) -> IDSocket
                -> ( IDSocket, Cmd Types.Msg )
handlePhoenixMsg msg idSocket =
  let
    ( newSocket, phxCmd ) =
      Phoenix.Socket.update msg idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )


pushMessage : String -> String -> Maybe JE.Value -> IDSocket
           -> ( IDSocket, Cmd Types.Msg )
pushMessage message channel payload idSocket =
  let
    push =
      Phoenix.Push.init message channel
    push_ =
      case payload of
        Just p  -> push |> Phoenix.Push.withPayload p
        Nothing -> push
    ( newSocket, phxCmd ) =
      Phoenix.Socket.push push_ idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )
