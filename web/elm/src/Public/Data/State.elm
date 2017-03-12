module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket, noPayload)
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
  { shows     = NotAsked
  , showExtra = NotAsked
  , events    = NotAsked
  , episodes  = NotAsked
  }

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model socket =
  case msg of
    SocketInitialized ->
      getData "shows" noPayload model socket ReceiveShows

    FetchNewStuff ->
      let
        ( _, cmd1, socket1 ) =
          getData "episodes" noPayload model socket ReceiveEpisodes
        ( _, cmd2, socket2 ) =
          getData "events" noPayload model socket1 ReceiveEvents
      in
        ( model, Cmd.batch [cmd1, cmd2], socket2 )

    FetchEpisodes page ->
      let payload = JE.object [ ("page", JE.int page) ]
      in  getData "episodes" payload model socket ReceiveEpisodes

    FetchEvents page ->
      let payload = JE.object [ ("page", JE.int page) ]
      in  getData "events" payload model socket ReceiveEvents

    FetchShowDetail slug ->
      ( model, Cmd.none, socket )

    ReceiveShows raw ->
      receiveData "ReceiveShows" showsDecoder raw model socket
        (\shows ->
            let model2 = { model | shows = Loaded shows }
            in  ( model2, Cmd.none, socket )
        )

    ReceiveEpisodes raw ->
      receiveData "ReceiveEpisodes" episodePagerDecoder raw model socket
        (\episodes ->
            let model2 = { model | episodes = Loaded episodes }
            in  ( model2, Cmd.none, socket )
        )

    ReceiveEvents raw ->
      receiveData "ReceiveEvents" eventPagerDecoder raw model socket
        (\events ->
            let model2 = { model | events = Loaded events }
            in  ( model2, Cmd.none, socket )
        )

    NoOp ->
      ( model, Cmd.none, socket )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none


getData : String -> JE.Value -> Model -> IDSocket -> (JE.Value -> Msg)
       -> ( Model, Cmd Types.Msg, IDSocket )
getData messageStr payload model idSocket retMsg =
  finishPush model <| pushMsgWithConfigurator
    messageStr "data" idSocket
    (\a -> Types.DataMsg <| retMsg a)
    ( case payload == noPayload of
        True  -> (\p -> p)
        False -> (\p -> p |> Phoenix.Push.withPayload payload)
    )


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
