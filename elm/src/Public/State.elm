module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Data.Types
import Chat.Types
import Photo.Types
import Navigation exposing (Location)
import Dom.Scroll
import Port
import Chat.State
import Data.State
import Photo.State
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Socket as Socket
import Phoenix.Push as Push
import StateUtil
import Defer
import Task


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route =
      parseLocation location
    data =
      Data.State.init
    ( chatModel, chatCmd ) =
      Chat.State.init
    ( section, routeCmd ) =
      StateUtil.routeCmd
        route data.shows data.events data.episodes
    model =
      { route    = route
      , section  = section
      , loading  = 0
      , chat     = chatModel
      , data     = data
      , photo    = Photo.State.init
      , player   = { track = Nothing }
      , video    = False
      , defer    = Defer.init []
      }
    cmd =
      Cmd.batch
        [ chatCmd
        , routeCmd
        ]
  in
    ( model, cmd )


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
        ( model2, initCmd ) =
          initPage model1
      in
        model2 ! [topCmd, initCmd]

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

    PlayEpisode url episode ->
      let
        player =
          model.player
        track =
          Just (Track url episode)
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

    -- PhoenixMsg msg_ ->
    --   let
    --     msg = Debug.log "PhoenixMsg" msg_
    --     ( newSocket, cmd ) =
    --       StateUtil.handlePhoenixMsg msg model.idSocket
    --   in
    --     { model | idSocket = newSocket }
    --     ! [ cmd ]

    SocketInitialized ->
      let
        _ = Debug.log "SocketInitialized" "Yeah!"
        ( dataModel, dataCmd ) =
          Data.State.update Data.Types.SocketInitialized model.data
        model2 =
          { model | data = dataModel }
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
        ( chatModel, chatCmd ) =
          Chat.State.update chatMsg model.chat
      in
        { model | chat = chatModel }
          ! [ chatCmd ]

    DataMsg dataMsg ->
      let
        ( dataModel, dataCmd ) =
          Data.State.update dataMsg model.data
      in
        { model | data = dataModel }
          ! [ dataCmd ]

    PhotoMsg photoMsg ->
      photoUpdate photoMsg model

    NoOp ->
      ( model, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
  let
    socket =
      Socket.init wsUrl
    lobbyChannel =
      Channel.init "rooms:lobby"
        |> Channel.on "new:msg" (\m -> ChatMsg (Chat.Types.ReceiveNewMsg m))
    dataChannel =
      Channel.init "data"
        |> Channel.on "shows" (\m -> DataMsg (Data.Types.ReceiveShows m))
        |> Channel.onJoin (\jv -> SocketInitialized)
    igChannel =
      Channel.init "instagram"
  in
    Sub.batch
      [ Phoenix.connect socket [lobbyChannel, dataChannel, igChannel]
      , Chat.State.subscriptions model
          |> Sub.map ChatMsg
      , Defer.subscriptions model.defer
          |> Sub.map DeferMsg
      ]



initPage : Model -> ( Model, Cmd Msg )
initPage model =
  let
    ( model1, cmd1 ) =
      doInitPage model
    ( section, routeCmd ) =
      StateUtil.routeCmd
        model1.route
        model1.data.shows
        model1.data.events
        model1.data.episodes
  in
    { model1 | section = section }
      ! [cmd1, routeCmd]


doInitPage : Model -> ( Model, Cmd Msg )
doInitPage model =
  case model.route of
    HomeRoute ->
      updateMap model
        [ dataUpdate Data.Types.FetchNewStuff
        , photoUpdate Photo.Types.FetchLastFour
        , update EnableVideo
        , (\m ->
             let
               toBottom = Dom.Scroll.toBottom "chat-messages"
             in
               ( { model | video = False } -- undo from EnableVideo
               , Task.attempt (\_ -> Types.NoOp) toBottom
               )
          )
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

    ShowInfoRoute slug ->
      dataUpdate (Data.Types.FetchShowDetail slug) model

    EventRoute slug evSlug ->
      dataUpdate (Data.Types.FetchEvent slug evSlug) model

    EpisodeRoute slug epSlug ->
      dataUpdate (Data.Types.FetchEpisode slug epSlug) model

    EpisodesRedirectorRoute ->
      goto model "#episodes/1"

    EventsRedirectorRoute ->
      goto model "#events/1"

    ShowEpisodesRedirectorRoute slug ->
      goto model ("#shows/" ++ slug ++ "/episodes/1")

    ShowEventsRedirectorRoute slug ->
      goto model ("#shows/" ++ slug ++ "/events/1")

    LegacyPodcastRoute slug epSlug ->
      goto model ("#shows/" ++ slug ++ "/episodes/" ++ epSlug)

    _ ->
      ( model, Cmd.none )


goto : Model -> String -> ( Model, Cmd Msg )
goto model url =
  ( model, Navigation.modifyUrl url )


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
    ( dataModel, cmd ) =
      Data.State.update msg model.data
  in
    { model | data = dataModel }
      ! [ cmd ]

photoUpdate : Photo.Types.Msg -> Model -> ( Model, Cmd Msg )
photoUpdate msg model =
  let
    ( photoModel, cmd, newDefer ) =
      Photo.State.update msg model.photo model.defer
  in
    { model | photo = photoModel , defer = newDefer }
      ! [ cmd ]
