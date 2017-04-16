module Data.State exposing (init, update, subscriptions)

import Types exposing (noPayload)
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

update : Msg -> Model
      -> ( Model, Cmd Types.Msg )
update msg model =
  case msg of
    SocketInitialized ->
      getData "shows" noPayload model ReceiveShows

    ReceiveShows raw ->
      receiveData "ReceiveShows" showsDecoder raw model
        (\shows ->
          let model2 = { model | shows = Loaded shows }
          in  ( model2, Cmd.none )
        )

    FetchNewStuff ->
      let
        ( _, cmd1 ) =
          getData "episodes" noPayload model ReceiveEpisodes
        ( _, cmd2 ) =
          getData "events" noPayload model ReceiveEvents
      in
        ( model, Cmd.batch [cmd1, cmd2] )

    FetchEvents page ->
      let payload = object [ ("page", int page) ]
      in  getData "events" payload model ReceiveEvents

    FetchEpisodes page ->
      let payload = object [ ("page", int page) ]
      in  getData "episodes" payload model ReceiveEpisodes

    FetchEvent slug evSlug ->
      let
        payload =
          object [ ("slug", string slug), ("evSlug", string evSlug) ]
      in
        getData "event" payload model ReceiveEvent

    FetchEpisode slug evSlug ->
      let
        payload =
          object [ ("slug", string slug), ("epSlug", string evSlug) ]
      in
        getData "episode" payload model ReceiveEpisode

    FetchShowEvents slug page ->
      let
        payload =
          object [ ("slug", string slug), ("page", int page) ]
      in
        getData "events" payload model ReceiveEvents

    FetchShowEpisodes slug page ->
      let
        payload =
          object [ ("slug", string slug), ("page", int page) ]
      in
        getData "episodes" payload model ReceiveEpisodes

    ReceiveEpisodes raw ->
      receiveData "ReceiveEpisodes" episodePagerDecoder raw model
        (\episodes ->
            let model2 = { model | episodes = Loaded episodes }
            in  ( model2, Cmd.none )
        )

    ReceiveEvents raw ->
      receiveData "ReceiveEvents" eventPagerDecoder raw model
        (\events ->
            let model2 = { model | events = Loaded events }
            in  ( model2, Cmd.none )
        )

    FetchShowDetail slug ->
      let payload = object [ ("slug", string slug) ]
      in  getData "show_detail" payload model ReceiveShowDetail

    ReceiveShowDetail raw ->
      receiveData "ReceiveShowDetail" showDetailDecoder raw model
        (\detail ->
            let model2 = { model | showDetail = Loaded detail }
            in  ( model2, Cmd.none )
        )

    ReceiveEpisode raw ->
      receiveData "ReceiveEpisodeDetail" episodeDecoder raw model
        (\episode ->
            let
              pager  = TypeUtil.Pager 0 0 0 0
              episodes = Loaded { entries = [episode], pager = pager }
              model2 = { model | episodes = episodes }
            in
              ( model2, Cmd.none )
        )

    ReceiveEvent raw ->
      receiveData "ReceiveEventDetail" eventDecoder raw model
        (\event ->
            let
              pager  = TypeUtil.Pager 0 0 0 0
              events = Loaded { entries = [event], pager = pager }
              model2 = { model | events = events }
            in
              ( model2, Cmd.none )
        )

    NoOp ->
      ( model, Cmd.none )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none


getData : String -> JE.Value -> Model -> (JE.Value -> Msg)
       -> ( Model, Cmd Types.Msg )
getData messageStr payload model retMsg =
  finishPush model <| pushMsgWithConfigurator
    messageStr
    "data"
    (\a -> Types.DataMsg <| retMsg a)
    ( case payload == noPayload of
        True  -> (\p -> p)
        False -> (\p -> p |> Phoenix.Push.withPayload payload)
    )


finishPush : Model -> Cmd Types.Msg
          -> ( Model, Cmd Types.Msg )
finishPush model msg =
  let
    newModel =
      { model | events = Loading, episodes = Loading }
  in
    ( newModel, msg )


receiveData : String -> Decoder a -> JE.Value -> Model
           -> (a -> ( Model, Cmd Types.Msg ))
           -> ( Model, Cmd Types.Msg )
receiveData name decoder raw model happyFn =
  case decodeValue decoder raw of
    Ok value ->
      happyFn value

    Err error ->
      let
        _ = Debug.log (name ++ " Error") error
        cmd = Navigation.modifyUrl "#404"
      in ( model, cmd )
