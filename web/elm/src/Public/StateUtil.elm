module StateUtil exposing (initSocket, pushMessage, handlePhoenixMsg)

-- import Types exposing (Model, Msg(PhoenixMsg, ChatMsg))
import Types exposing (..)
import Chat.Types
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
-- import Chat.Types exposing (Line)

initSocket : ( ( Phoenix.Socket.Socket Types.Msg ), Cmd Types.Msg )
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


handlePhoenixMsg : (Phoenix.Socket.Msg Types.Msg) -> Model
                -> ( Model, Cmd Types.Msg )
handlePhoenixMsg msg model =
  let
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.update msg model.phxSocket
  in
    ( { model | phxSocket = phxSocket }
    , Cmd.map PhoenixMsg phxCmd
    )


pushMessage : String -> String -> JE.Value -> Model
           -> ( Model, Cmd Types.Msg )
pushMessage message channel payload model =
  let
    push_ =
      Phoenix.Push.init message channel
        |> Phoenix.Push.withPayload payload
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.push push_ model.phxSocket
  in
    ( { model | phxSocket = phxSocket }
    , Cmd.map PhoenixMsg phxCmd
    )
