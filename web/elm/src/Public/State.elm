module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Navigation exposing (Location, newUrl)
import Port exposing (activateVideo, playEpisode)
import Dock.Types
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
      , dock      = { track = Nothing }
      , video     = False
      }
    , cmd
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
      StateUtil.handlePhoenixMsg msg model

    ChatMsg chatMsg ->
      let
        (model_, cmd) =
          Chat.State.update chatMsg model
      in
        ( model_
        , cmd
        )
        -- , Cmd.map ChatMsg cmd)

    NoOp ->
      ( model, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg
