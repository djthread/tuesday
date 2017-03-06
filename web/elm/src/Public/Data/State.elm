module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Data.Types exposing (..)
import Data.Codec exposing (..)
import StateUtil exposing (pushMessage)
import TypeUtil exposing (RemoteData(..))
-- import Port
import Json.Decode exposing (decodeValue)
import Phoenix.Push
import Json.Encode as JE
-- import Task
import Dom.Scroll
import Task

init : Model
init =
  { shows    = NotAsked
  , events   = NotAsked
  , episodes = NotAsked
  }

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
  case msg of
    SocketInitialized ->
      pushDataMsg
        "shows" "data" model idSocket ReceiveShows

    ReceiveShows raw ->
      case decodeValue showsDecoder raw of
        Ok shows ->
          ( { model | shows = Loaded shows }
          , Cmd.none
          , idSocket
          )

        Err error ->
          let _ = Debug.log "ReceiveShows Error" error
          in ( model, Cmd.none, idSocket )

    FetchNewStuff ->
      let
        ( model1, cmd1, socket1 ) =
          pushDataMsg
            "episodes" "data" model idSocket ReceiveEpisodes
        -- ( model2, cmd2, socket2 ) =
        --   pushDataMsg
        --     "events" "data" model1 socket1 ReceiveEvents
      in
        ( model1, cmd1, socket1 )
        -- ( model2, Cmd.batch [cmd1, cmd2], socket2 )

    FetchEpisodes page ->
      let
        payload =
          JE.object [ ("page", JE.int page) ]
      in
        pushDataMsgWithConfigurator
          "episodes" "data" model idSocket ReceiveEpisodes
          (\p -> p |> Phoenix.Push.withPayload payload)

    FetchEvents page ->
      let
        payload =
          JE.object [ ("page", JE.int page) ]
      in
        pushDataMsgWithConfigurator
          "events" "data" model idSocket ReceiveEvents
          (\p -> p |> Phoenix.Push.withPayload payload)

    ReceiveEpisodes raw ->
      case decodeValue episodePagerDecoder raw of
        Ok data ->
          let
            toTop = Dom.Scroll.toTop "body"
          in
            ( { model | episodes = Loaded data }
            , Task.attempt (\_ -> Types.NoOp) toTop
            , idSocket
            )

        Err error ->
          let _ = Debug.log "ReceiveEpisodes Error" error
          in ( model, Cmd.none, idSocket )

    ReceiveEvents raw ->
      case decodeValue eventPagerDecoder raw of
        Ok data ->
          let
            toTop = Dom.Scroll.toTop "body"
          in
            ( { model | events = Loaded data }
            , Task.attempt (\_ -> Types.NoOp) toTop
            , idSocket
            )

        Err error ->
          let _ = Debug.log "ReceiveEvents Error" error
          in ( model, Cmd.none, idSocket )

    NoOp ->
      ( model, Cmd.none, idSocket )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none


pushDataMsg : String -> String -> Model -> IDSocket
           -> (JE.Value -> Msg)
           -> ( Model, Cmd Types.Msg, IDSocket )
pushDataMsg message channel model idSocket msg =
  pushDataMsgWithConfigurator
    message channel model idSocket msg (\a -> a)

pushDataMsgWithConfigurator : String -> String
           -> Model -> IDSocket -> (JE.Value -> Msg)
           -> (Phoenix.Push.Push Types.Msg
              -> Phoenix.Push.Push Types.Msg )
           -> ( Model, Cmd Types.Msg, IDSocket )
pushDataMsgWithConfigurator
  message channel model idSocket msg configurator =
  let
    retDataMsg =
      (\d -> Types.DataMsg (msg d))
    configurator2 =
      (\p -> p |> Phoenix.Push.onOk retDataMsg |> configurator)
    ( newSocket, cmd ) =
      pushMessage message channel configurator2 idSocket
  in
    ( model, cmd, newSocket )
