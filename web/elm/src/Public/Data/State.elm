module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Data.Types exposing (..)
import Data.Codec exposing (..)
import StateUtil exposing (pushMsg, pushMsgWithConfigurator)
import TypeUtil exposing (RemoteData(..))
-- import Port
import Json.Decode exposing (Decoder, decodeValue)
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
      getData "shows" (JE.string "") model idSocket ReceiveShows

    FetchNewStuff ->
      let
        ( _, cmd1, socket1 ) =
          getData "episodes" (JE.string "") model idSocket ReceiveEpisodes
        ( _, cmd2, socket2 ) =
          getData "events" (JE.string "") model socket1 ReceiveEvents
      in
        ( model, Cmd.batch [cmd1, cmd2], socket2 )

    FetchEpisodes page ->
      let payload = JE.object [ ("page", JE.int page) ]
      in  getData "episodes" payload model idSocket ReceiveEpisodes

    FetchEvents page ->
      let payload = JE.object [ ("page", JE.int page) ]
      in  getData "events" payload model idSocket ReceiveEvents

    FetchShowDetail slug ->
      ( model, Cmd.none, idSocket )

    ReceiveShows raw ->
      receiveData "ReceiveShows" showsDecoder raw
        model idSocket
          (\shows ->
              let model2 = { model | shows = Loaded shows }
              in  ( model2, Cmd.none, idSocket )
          )

    ReceiveEpisodes raw ->
      receiveData "ReceiveEpisodes" episodePagerDecoder raw
        model idSocket
          (\episodes ->
              let model2 = { model | episodes = Loaded episodes }
              in  ( model2, Cmd.none, idSocket )
          )

    ReceiveEvents raw ->
      receiveData "ReceiveEvents" eventPagerDecoder raw
        model idSocket
          (\events ->
              let model2 = { model | events = Loaded events }
              in  ( model2, Cmd.none, idSocket )
          )

    NoOp ->
      ( model, Cmd.none, idSocket )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none


getData : String -> JE.Value -> Model -> IDSocket -> (JE.Value -> Msg)
       -> ( Model, Cmd Types.Msg, IDSocket )
getData messageStr payload model idSocket retMsg =
  finishPush model <| pushMsgWithConfigurator
    messageStr "data" idSocket
    (\a -> Types.DataMsg <| retMsg a)
    (\p -> p |> Phoenix.Push.withPayload payload)


finishPush : Model -> ( Cmd Types.Msg, IDSocket )
          -> ( Model, Cmd Types.Msg, IDSocket )
finishPush model (msg, socket) =
  ( model, msg, socket )


receiveData : String -> Decoder a -> JE.Value -> Model -> IDSocket
           -> (a -> ( Model, Cmd Types.Msg, IDSocket ))
           -> ( Model, Cmd Types.Msg, IDSocket )
receiveData name decoder raw model idSocket happyFn =
  case decodeValue decoder raw of
    Ok value ->
      happyFn value
    Err error ->
      let _ = Debug.log (name ++ " Error") error
      in ( model, Cmd.none, idSocket )
