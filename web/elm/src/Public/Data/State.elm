module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Data.Types exposing (..)
import Data.Codec exposing (..)
import StateUtil exposing (pushMessage)
import TypeUtil exposing (RemoteData(..))
-- import Port
import Json.Decode exposing (decodeValue)
import Phoenix.Push
-- import Json.Encode as JE
-- import Task

init : Model
init =
  { shows          = NotAsked
  , upcomingEvents = NotAsked
  , recentEpisodes = NotAsked
  , viewedEvents   = NotAsked
  , viewedEpisodes = NotAsked
  }

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
  case msg of
    ReceiveShows raw ->
      case decodeValue showsDecoder raw of
        Ok shows ->
          let
            foo =
              shows
                |> Debug.log "AOEUDAOEUTDOAEUTOADEU"
          in
            ( model, Cmd.none, idSocket )

        Err error ->
          ( model, Cmd.none, idSocket )

    ReceiveNewStuff raw ->
      ( model, Cmd.none, idSocket )
      -- case decodeValue newStuffDecoder raw of
      --   Ok data ->
      --     let

    SocketInitialized ->
      let
        retShowsMsg =
          (\m -> Types.DataMsg (ReceiveShows m))
        configurator1 = 
          (\p -> p |> Phoenix.Push.onOk retShowsMsg)
        ( newSocket1, cmd1 ) =
          pushMessage "shows" "data" configurator1 idSocket
        retDataMsg =
          (\d -> Types.DataMsg (ReceiveNewStuff d))
        configurator2 =
          (\p -> p |> Phoenix.Push.onOk retDataMsg)
        ( newSocket2, cmd2 ) =
          pushMessage "new" "data" configurator2 newSocket1
        cmd =
          Cmd.batch [cmd1, cmd2]
      in
        ( model, cmd, newSocket2 )

    NoOp ->
      ( model, Cmd.none, idSocket )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none



-- pushFetchMessage : Model -> IDSocket
--                 -> ( Model, Cmd Types.Msg, IDSocket )
-- pushFetchMessage model idSocket =
--   let
--     -- payload =
--     --   JE.object
--     --     [ ( "user", JE.string model.name )
--     --     , ( "body", JE.string model.msg )
--     --     ]
--     ( newSocket, cmd ) =
--       pushMessage "new:msg" "rooms:lobby" payload idSocket
--   in
--     ( model
--     , cmd
--     , newSocket
--     )
