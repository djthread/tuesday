module StateUtil exposing (..)

import Types exposing (..)
import TypeUtil exposing (RemoteData(..))
import Chat.Types
import Data.Types exposing (findShowBySlug)
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Routing exposing (Route, Route(..))
import Port

wsUrl : String
wsUrl =
  -- "wss://api.impulsedetroit.net/socket/websocket"
  "ws://localhost:4091/socket/websocket"


routeCmd : Route -> Cmd Msg
routeCmd route =
  let
    string_ =
      case route of
        HomeRoute       -> ""
        ShowsRoute      -> "Shows"
        ShowRoute _     -> "Show"
        EpisodesRoute _ -> "Episodes"
        EventsRoute _   -> "Events"
        AboutRoute      -> "About"
        NotFoundRoute   -> ""
    string =
      if String.length string_ > 0 then
        string_ ++ " : "
      else ""
  in
    Port.setTitle (string ++ "Impulse Detroit")


startLoading : Model -> Model
startLoading model =
  let
    newCount = model.loading + 1
  in
    { model | loading = newCount }

doneLoading : Model -> Model
doneLoading model =
  let
    newCount = model.loading - 1
  in
    { model | loading = newCount }

initSocket : ( (Phoenix.Socket.Socket Types.Msg), Cmd Types.Msg )
initSocket =
  let
    initSocket =
      wsUrl
        |> Phoenix.Socket.init
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:lobby"
            (\m -> ChatMsg (Chat.Types.ReceiveNewMsg m))
        |> Phoenix.Socket.on "shows" "data"
            (\m -> DataMsg (Data.Types.ReceiveShows m))
    channel =
      Phoenix.Channel.init "rooms:lobby"
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.join channel initSocket
    onJoin =
      always SocketInitialized
    channel2 =
      Phoenix.Channel.init "data"
        |> Phoenix.Channel.onJoin onJoin
    ( phxSocket2, phxCmd2 ) =
      Phoenix.Socket.join channel2 phxSocket
    channel3 =
      Phoenix.Channel.init "instagram"
    ( phxSocket3, phxCmd3 ) =
      Phoenix.Socket.join channel3 phxSocket2
    cmd =
      Cmd.batch
        [ Cmd.map PhoenixMsg phxCmd
        , Cmd.map PhoenixMsg phxCmd2
        , Cmd.map PhoenixMsg phxCmd3
        ]
  in
    ( phxSocket3, cmd )



handlePhoenixMsg : (Phoenix.Socket.Msg Types.Msg) -> IDSocket
                -> ( IDSocket, Cmd Types.Msg )
handlePhoenixMsg msg idSocket =
  let
    ( newSocket, phxCmd ) =
      Phoenix.Socket.update msg idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )



pushMessage : String -> String
           -> (Phoenix.Push.Push Msg -> Phoenix.Push.Push Msg)
           -> IDSocket
           -> ( IDSocket, Cmd Types.Msg )
pushMessage message channel configurator idSocket =
  let
    push =
      configurator (Phoenix.Push.init message channel)
    ( newSocket, phxCmd ) =
      Phoenix.Socket.push push idSocket
  in
    ( newSocket, Cmd.map PhoenixMsg phxCmd )
