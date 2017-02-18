module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Navigation exposing (Location, newUrl)
import Port exposing (activateVideo, playEpisode)
import Dock.Types
import Chat.Types exposing (Line)
import Chat.Modem exposing (newMsgDecoder)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
import Date exposing (Date)
import Task
-- import Phoenix.Push


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    initSocket =
      Phoenix.Socket.init "ws://localhost:4091/socket/websocket"
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:lobby" ReceiveNewMsg
    channel =
      Phoenix.Channel.init "rooms:lobby"
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.join channel initSocket
  in
    ( { route     = route
      , phxSocket = phxSocket
      , chat =
          { name  = ""
          , msg   = ""
          , lines = Nothing
          }
      , dock      = { track = Nothing }
      , video     = False
      }
    , Cmd.map PhoenixMsg phxCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case Debug.log "msg" msg of
    OnLocationChange location ->
      let
        route = parseLocation location
      in
        ( { model | route = route }
        , Cmd.none )

    EnableVideo ->
      ( { model | video = True }
      , activateVideo "yeap"
      )

    PlayEpisode url title ->
      let
        dock  = model.dock
        track = Dock.Types.Track url title
      in
        ( { model
          | dock =
              { dock | track = Just track }
          }
        , playEpisode "go beach"
        )

    PhoenixMsg msg ->
      let
        ( phxSocket, phxCmd ) =
          Phoenix.Socket.update msg model.phxSocket
      in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

    ReceiveNewMsg raw ->
      case decodeValue newMsgDecoder raw of
        Ok line ->
          let
            -- now  = Date.now |> Task.Perform NoOp CurrentTime
            -- line = Line now "Bob" "Cheese"
            chat =
              model.chat
            lines =
              case chat.lines of
                Just lines -> Just (lines ++ [line])
                Nothing ->    Just [line]
          in
            ( { model | chat = { chat | lines = lines } }
            , Cmd.none
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
        13 ->   -- enter
          pushChatMessage model

        _ ->
          update NoOp model

    -- ScrollToBottom ->
    --   scrollToBottom

    NoOp ->
      ( model, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg


pushChatMessage : Model -> ( Model, Cmd Msg )
pushChatMessage model =
  let
    ( model_, cmd ) =
      pushMessage "new:msg" "rooms:lobby" model
    chat =
      model_.chat
  in
    ( { model_ | chat = { chat | msg = "" } }
    , cmd
    )


pushMessage : String -> String -> Model -> ( Model, Cmd Msg )
pushMessage message channel model =
  let
    payload =
      JE.object
        [ ( "user", JE.string model.chat.name )
        , ( "body", JE.string model.chat.msg )
        ]
    push_ =
      Phoenix.Push.init message channel
        |> Phoenix.Push.withPayload payload
    ( phxSocket, phxCmd ) =
      Phoenix.Socket.push push_ model.phxSocket
  in
    ( { model | phxSocket = phxSocket }
    , Cmd.map PhoenixMsg phxCmd
    )
