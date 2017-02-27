module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Data.Types
import Navigation exposing (Location, newUrl)
import Port
import Chat.State
import Data.State
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import StateUtil


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    ( idSocket, phxCmd ) =
      StateUtil.initSocket
    ( chatModel, chatCmd ) =
      Chat.State.init
  in
    ( { route    = route
      , loading  = 0
      , idSocket = idSocket
      , chat     = chatModel
      , data     = Data.State.init
      , player   = { track = Nothing }
      , video    = False
      }
    , Cmd.batch
        [ phxCmd
        , chatCmd
        , Port.getChatName "fo srs"
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case Debug.log "msg" msg of
    OnLocationChange location ->
      let
        route = parseLocation location
      in
        ( { model | route = route }
        , Cmd.none
        )

    NavigateTo url ->
      ( model, Navigation.newUrl url )

    EnableVideo ->
      ( { model | video = True }
      , Port.activateVideo "yeap"
      )

    ClosePlayer ->
      ( { model | player = { track = Nothing } }
      , Cmd.none
      )

    PlayEpisode url title ->
      let
        player = model.player
        track  = Just (Track url title)
      in
        ( { model
          | player = { player | track = track }
          }
        , Port.playEpisode "go beach"
        )

    PhoenixMsg msg ->
      let
        ( newSocket, cmd ) =
          StateUtil.handlePhoenixMsg msg
            model.idSocket
      in
        ( { model | idSocket = newSocket }
        , cmd
        )

    SocketInitialized ->
      let
        ( dataModel, dataCmd, newSocket ) =
          Data.State.update
            Data.Types.SocketInitialized
            model.data
            model.idSocket
      in
        ( { model
          | data = dataModel
          , idSocket = newSocket
          }
        , dataCmd
        )

    ChatMsg chatMsg ->
      let
        ( chatModel, chatCmd, newSocket ) =
          Chat.State.update chatMsg model.chat
            model.idSocket
      in
        ( { model
          | chat = chatModel
          , idSocket = newSocket
          }
        , chatCmd
        )

    DataMsg dataMsg ->
      let
        ( dataModel, dataCmd, newSocket ) =
          Data.State.update dataMsg model.data
            model.idSocket
          -- |> Debug.log "WTFFFFF"
      in
        ( { model
          | data = dataModel
          , idSocket = newSocket
        }
        , dataCmd
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
      [ Phoenix.Socket.listen
          model.idSocket
          PhoenixMsg
      , Sub.map ChatMsg chatSub
      ]
