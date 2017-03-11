module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Data.Types exposing (..)
import Data.Codec exposing (..)
import StateUtil exposing (pushMsg, pushMsgWithConfigurator)
import TypeUtil exposing (RemoteData(..))
-- import Port
import Json.Decode exposing (decodeValue)
import Phoenix.Push
import Json.Encode as JE
-- import Task
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
      finishPush model <| pushMsg
        "shows" "data" idSocket
          (\a -> Types.DataMsg <| ReceiveShows a)

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
        ( cmd1, socket1 ) =
          pushMsg
            "episodes" "data" idSocket
            (\a -> Types.DataMsg <| ReceiveEpisodes a)
        ( cmd2, socket2 ) =
          pushMsg
            "events" "data" socket1
            (\a -> Types.DataMsg <| ReceiveEvents a)
      in
        ( model, Cmd.batch [cmd1, cmd2], socket2 )

    FetchEpisodes page ->
      let
        payload =
          JE.object [ ("page", JE.int page) ]
      in
        finishPush model <| pushMsgWithConfigurator
          "episodes" "data" idSocket
          (\a -> Types.DataMsg <| ReceiveEpisodes a)
          (\p -> p |> Phoenix.Push.withPayload payload)

    FetchEvents page ->
      let
        payload =
          JE.object [ ("page", JE.int page) ]
      in
        finishPush model <| pushMsgWithConfigurator
          "events" "data" idSocket
          (\a -> Types.DataMsg <| ReceiveEvents a)
          (\p -> p |> Phoenix.Push.withPayload payload)

    ReceiveEpisodes raw ->
      case decodeValue episodePagerDecoder raw of
        Ok data ->
          ( { model | episodes = Loaded data }
          , Cmd.none
          , idSocket
          )

        Err error ->
          let _ = Debug.log "ReceiveEpisodes Error" error
          in ( model, Cmd.none, idSocket )

    ReceiveEvents raw ->
      case decodeValue eventPagerDecoder raw of
        Ok data ->
          ( { model | events = Loaded data }
          , Cmd.none
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


finishPush : Model -> ( Cmd Types.Msg, IDSocket )
          -> ( Model, Cmd Types.Msg, IDSocket )
finishPush model (msg, socket) =
  ( model, msg, socket )

