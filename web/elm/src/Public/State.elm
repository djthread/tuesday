module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Navigation exposing (Location, newUrl)
import Port
import Chat.State
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import StateUtil


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    ( phxSocket, cmd ) =
      StateUtil.initSocket
  in
    ( { route     = route
      , phxSocket = phxSocket
      , chat =
          { name  = ""
          , msg   = ""
          , lines = Nothing
          }
      , player = { track = Nothing }
      , video  = False
      }
    , Cmd.batch [ cmd, Port.getChatName "fo srs"]
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
      , Port.activateVideo "yeap"
      )

    PlayEpisode url title ->
      let
        player = model.player
        track  = Just (Track url title)
      in
        ( { model | player = { player | track = track } }
        , Port.playEpisode "go beach"
        )

    PhoenixMsg msg ->
      StateUtil.handlePhoenixMsg msg model

    ChatMsg chatMsg ->
      let
        (model_, cmd) =
          Chat.State.update chatMsg model
      in
        ( model_
        , cmd
        )

    NoOp ->
      ( model, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
  let
    chatSub =
      Chat.State.subscriptions model
  in
    Sub.batch
      [ Phoenix.Socket.listen model.phxSocket PhoenixMsg
      , Sub.map ChatMsg chatSub
      ]
