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
import Json.Decode exposing (decodeValue)
import Date exposing (Date)
import Task
-- import Phoenix.Push


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    initSocket =
      Phoenix.Socket.init "/socket"
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
  case msg of
    OnLocationChange location ->
      let
        route = parseLocation location
      in
        ( { model | route = route }
        , Cmd.none )

    EnableVideo ->
      ( { model | video = True }
      , Debug.log "sap" (activateVideo "yeap")
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
            chat = model.chat
          in
            ( { model | chat = { chat | lines = Just [line] } }
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

    NoOp ->
      ( model, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg
