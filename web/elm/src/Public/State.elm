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
import Defer


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
      , defer    = Defer.init []
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
        newModel =
          { model | route = parseLocation location }
      in
        initPage newModel

    NavigateTo url ->
      ( model, Navigation.newUrl url )

    EnableVideo ->
      let
        cmd =
          Port.activateVideo "hteud"
        ( deferModel, deferCmd ) =
          Defer.update (Defer.AddCmd cmd) model.defer
      in
        ( { model
          | video = True
          , defer = deferModel
          }
        , Cmd.map DeferMsg deferCmd
        )

    PlayEpisode url title ->
      let
        player =
          model.player
        track =
          Just (Track url title)
        cmd =
          Port.playEpisode "x"
        ( deferModel, deferCmd ) =
          Defer.update (Defer.AddCmd cmd) model.defer
      in
        ( { model
          | player = { player | track = track }
          , defer  = deferModel
          }
        , Cmd.map DeferMsg deferCmd
        )

    ClosePlayer ->
      ( { model | player = { track = Nothing } }
      , Cmd.none
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
        model2 =
          { model
          | data = dataModel
          , idSocket = newSocket
          }
        ( model3, cmd ) =
          initPage model2
      in
        ( model3, Cmd.batch [ dataCmd, cmd ] )

    DeferMsg deferMsg ->
      let
        ( deferModel, deferCmd ) =
          Defer.update deferMsg model.defer
      in
        ( { model | defer = deferModel }
        , Cmd.map DeferMsg deferCmd
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
      , Defer.subscriptions model.defer
          |> Sub.map DeferMsg
      ]



initPage : Model -> ( Model, Cmd Msg )
initPage model =
  case model.route of
    HomeRoute ->
      dataUpdate Data.Types.FetchNewStuff model

    EpisodesRoute page ->
      dataUpdate (Data.Types.FetchEpisodes page) model

    EventsRoute page ->
      dataUpdate (Data.Types.FetchEvents page) model

    _ ->
      ( model, Cmd.none )



dataUpdate : Data.Types.Msg -> Model -> ( Model, Cmd Msg )
dataUpdate msg model =
  let
    ( dataModel, cmd, idSocket ) =
      Data.State.update msg model.data model.idSocket
  in
    ( { model | data = dataModel, idSocket = idSocket }
    , cmd
    )
