module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket, noPayload)
import Data.Types exposing (..)
import Data.Codec exposing (..)
import StateUtil exposing (pushMsg, pushMsgWithConfigurator)
import TypeUtil exposing (RemoteData(..))
-- import Port
import Json.Decode exposing (Decoder, decodeValue)
import Phoenix.Push
import Json.Encode as JE exposing (int, string, object)
-- import Task
import Task
import Navigation

init : Model
init =
  { shows      = NotAsked
  , showDetail = NotAsked
  , events     = NotAsked
  , episodes   = NotAsked
  }

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model socket =
  case Debug.log "DATAMSG" msg of
    SocketInitialized ->
      getData "shows" noPayload model socket ReceiveShows

    ReceiveShows raw ->
      receiveData "ReceiveShows" showsDecoder raw model socket
        (\shows ->
            let model2 = { model | shows = Loaded shows }
            in  ( model2, Cmd.none, socket )
        )

    FetchNewStuff ->
      let
        ( _, cmd1, socket1 ) =
          getData "episodes" noPayload model socket ReceiveEpisodes
        ( _, cmd2, socket2 ) =
          getData "events" noPayload model socket1 ReceiveEvents
      in
        ( model, Cmd.batch [cmd1, cmd2], socket2 )

    FetchEvents page ->
      let payload = object [ ("page", int page) ]
      in  getData "events" payload model socket ReceiveEvents

    FetchEpisodes page ->
      let payload = object [ ("page", int page) ]
      in  getData "episodes" payload model socket ReceiveEpisodes

    FetchEvent slug evSlug ->
      let
        payload =
          object [ ("slug", string slug), ("evSlug", string evSlug) ]
      in
        getData "event" payload model socket ReceiveEvent

    FetchEpisode slug evSlug ->
      let
        payload =
          object [ ("slug", string slug), ("epSlug", string evSlug) ]
      in
        getData "episode" payload model socket ReceiveEpisode

    FetchShowEvents slug page ->
      let
        payload =
          object [ ("slug", string slug), ("page", int page) ]
      in
        getData "events" payload model socket ReceiveEvents

    FetchShowEpisodes slug page ->
      let
        payload =
          object [ ("slug", string slug), ("page", int page) ]
      in
        getData "episodes" payload model socket ReceiveEpisodes

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

    FetchShowDetail slug ->
      let payload = object [ ("slug", string slug) ]
      in  getData "show_detail" payload model socket ReceiveShowDetail

    ReceiveShowDetail raw ->
      receiveData "ReceiveShowDetail" showDetailDecoder raw model socket
        (\detail ->
            let model2 = { model | showDetail = Loaded detail }
            in  ( model2, Cmd.none, socket )
        )

    ReceiveEpisode raw ->
      receiveData "ReceiveEpisodeDetail" episodeDecoder raw model socket
        (\episode ->
            let
              pager  = TypeUtil.Pager 0 0 0 0
              episodes = Loaded { entries = [episode], pager = pager }
              model2 = { model | episodes = episodes }
            in
              ( model2, Cmd.none, socket )
        )

    ReceiveEvent raw ->
      receiveData "ReceiveEventDetail" eventDecoder raw model socket
        (\event ->
            let
              pager  = TypeUtil.Pager 0 0 0 0
              events = Loaded { entries = [event], pager = pager }
              model2 = { model | events = events }
            in
              ( model2, Cmd.none, socket )
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
  let
    newModel =
      { model | events = Loading, episodes = Loading }
  in
    ( newModel, msg, socket )


receiveData : String -> Decoder a -> JE.Value -> Model -> IDSocket
           -> (a -> ( Model, Cmd Types.Msg, IDSocket ))
           -> ( Model, Cmd Types.Msg, IDSocket )
receiveData name decoder raw model idSocket happyFn =
  case decodeValue decoder raw of
    Ok value ->
      happyFn value

    Err error ->
      let
        _ = Debug.log (name ++ " Error") error
        cmd = Navigation.newUrl "#404"
      in ( model, cmd, idSocket )
