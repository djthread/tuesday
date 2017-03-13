module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Data.Types
import Photo.Types
import Navigation exposing (Location, newUrl)
import Dom.Scroll
import Port
import Chat.State
import Data.State
import Photo.State
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import StateUtil
import Defer
import Task


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    routeCmd =
      StateUtil.routeCmd route
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
      , photo    = Photo.State.init
      , player   = { track = Nothing }
      , video    = False
      , defer    = Defer.init []
      }
    , Cmd.batch
        [ phxCmd
        , chatCmd
        , routeCmd
        , Port.getChatName "fo srs"
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        topCmd =
          Task.attempt
            (\_ -> Types.NoOp)
            (Dom.Scroll.toTop "body")
        model1 =
          { model | route = parseLocation location }
        routeCmd =
          StateUtil.routeCmd model1.route
        ( model2, initCmd ) =
          initPage model1
      in
        model2 ! [topCmd, routeCmd, initCmd]

    NavigateTo url ->
      ( model, Navigation.newUrl url )

    EnableVideo ->
      let
        cmd =
          Port.activateVideo "hteud"
        ( deferModel, deferCmd ) =
          Defer.update (Defer.AddCmd cmd) model.defer
      in
        { model | video = True, defer = deferModel }
        ! [ Cmd.map DeferMsg deferCmd ]

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
      { model | player = { track = Nothing } }
      ! []

    PhoenixMsg msg ->
      let
        ( newSocket, cmd ) =
          StateUtil.handlePhoenixMsg msg
            model.idSocket
      in
        { model | idSocket = newSocket }
        ! [ cmd ]

    SocketInitialized ->
      let
        _ = Debug.log "SocketInitialized" "Yeah!"
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
        model3 ! [ dataCmd, cmd ]

    DeferMsg deferMsg ->
      let
        ( deferModel, deferCmd ) =
          Defer.update deferMsg model.defer
      in
        { model | defer = deferModel }
        ! [ Cmd.map DeferMsg deferCmd ]

    ChatMsg chatMsg ->
      let
        ( chatModel, chatCmd, newSocket ) =
          Chat.State.update chatMsg model.chat
            model.idSocket
      in
        { model | chat = chatModel, idSocket = newSocket }
        ! [ chatCmd ]

    DataMsg dataMsg ->
      let
        ( dataModel, dataCmd, newSocket ) =
          Data.State.update dataMsg model.data
            model.idSocket
      in
        { model | data = dataModel, idSocket = newSocket }
        ! [ dataCmd ]

    PhotoMsg photoMsg ->
      photoUpdate photoMsg model

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
      updateMap model
        [ dataUpdate Data.Types.FetchNewStuff
        , photoUpdate Photo.Types.FetchLastFour
        ]

    EpisodesRoute page ->
      dataUpdate (Data.Types.FetchEpisodes page) model

    EventsRoute page ->
      dataUpdate (Data.Types.FetchEvents page) model

    ShowRoute slug ->
      updateMap model
        [ dataUpdate (Data.Types.FetchShowDetail slug)
        , dataUpdate (Data.Types.FetchShowEvents slug 1)
        , dataUpdate (Data.Types.FetchShowEpisodes slug 1)
        ]

    ShowEpisodesRoute slug page ->
      dataUpdate (Data.Types.FetchShowEpisodes slug page) model

    ShowEventsRoute slug page ->
      dataUpdate (Data.Types.FetchShowEvents slug page) model

    EventRoute slug evSlug ->
      dataUpdate (Data.Types.FetchEvent slug evSlug) model

    EpisodeRoute slug epSlug ->
      dataUpdate (Data.Types.FetchEpisode slug epSlug) model

    LegacyPodcastRoute slug epSlug ->
      let
        url =
          ("#shows/" ++ slug ++ "/episodes/" ++ epSlug)
      in
        ( model, Navigation.newUrl url )

    _ ->
      ( model, Cmd.none )


updateMap : Model -> List (Model -> ( Model, Cmd Msg ))
         -> ( Model, Cmd Msg )
updateMap model list =
  let
    func =
      \updateFn ( m1, c1 ) ->
        let ( m2, c2 ) = updateFn m1
        in  m2 ! [c1, c2]
  in
    List.foldr func ( model, Cmd.none ) list


dataUpdate : Data.Types.Msg -> Model -> ( Model, Cmd Msg )
dataUpdate msg model =
  let
    ( dataModel, cmd, idSocket ) =
      Data.State.update msg model.data model.idSocket
  in
    { model | data = dataModel, idSocket = idSocket }
    ! [ cmd ]

photoUpdate : Photo.Types.Msg -> Model -> ( Model, Cmd Msg )
photoUpdate msg model =
  let
    ( photoModel, cmd, idSocket, newDefer ) =
      Photo.State.update msg model.photo model.idSocket
        model.defer
  in
    { model
    | photo    = photoModel
    , idSocket = idSocket
    , defer    = newDefer
    }
      ! [ cmd ]
