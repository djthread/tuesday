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
      pushDataMsg
        "new" "data" model idSocket ReceiveNewStuff

    ReceiveNewStuff raw ->
      case decodeValue newStuffDecoder raw of
        Ok data ->
          ( { model
            | upcomingEvents = Loaded data.events
            , recentEpisodes = Loaded data.episodes
            }
          , Cmd.none
          , idSocket
          )

        Err error ->
          let _ = Debug.log "ReceiveNewStuff Error" error
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
  let
    retDataMsg =
      (\d -> Types.DataMsg (msg d))
    configurator =
      (\p -> p |> Phoenix.Push.onOk retDataMsg)
    ( newSocket, cmd ) =
      pushMessage message channel configurator idSocket
  in
    ( model, cmd, newSocket )
