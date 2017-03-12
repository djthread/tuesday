module Photo.State exposing (init, update, subscriptions)

import Types exposing (IDSocket, Msg(DeferMsg))
import TypeUtil exposing (RemoteData(..))
import Photo.Types exposing (..)
import Photo.Codec exposing (lastFourDecoder, restListDecoder)
import Port
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
import StateUtil exposing (pushMsg)
import Defer

init : Model
init =
  NotAsked

update : Photo.Types.Msg -> Photo.Types.Model -> IDSocket
      -> Defer.Model
      -> ( Photo.Types.Model
         , Cmd Types.Msg
         , IDSocket
         , Defer.Model
         )
update msg model socket defer =
  case msg of
    FetchLastFour ->
      fetch model socket defer "last_four" ReceiveLastFour

    ShowNextFour ->
      case model of
        Loaded model_ ->
          if (List.length model_.list) == 4 then
            fetch model socket defer "rest" ReceiveRest
          else
            let
              last_page =
                (toFloat model_.total) / 4 |> ceiling
              page =
                if model_.page == last_page then
                  1
                else
                  model_.page + 1

            in
              ( Loaded { model_ | page = page }
              , Cmd.none
              , socket
              , defer
              )
        _ ->
          ( model, Cmd.none, socket, defer )

    ReceiveLastFour raw ->
      case decodeValue lastFourDecoder raw of
        Ok l4 ->
          let
            cmd =
              Port.activateLightbox "ya"
            ( newDefer, deferCmd ) =
              Defer.update (Defer.AddCmd cmd) defer
          in
            ( Loaded
                { list  = l4.last_four
                , total = l4.total
                , page  = 1
                }
            , Cmd.map Types.DeferMsg deferCmd
            , socket
            , newDefer
            )

        Err error ->
          let _ = Debug.log "ReceiveLastFour Error" error
          in ( model, Cmd.none, socket, defer )

    ReceiveRest raw ->
      case decodeValue restListDecoder raw of
        Ok rest ->
          let
            toDeferCmd =
              Port.activateLightbox "ya"
            ( newDefer, deferCmd ) =
              Defer.update (Defer.AddCmd toDeferCmd) defer
            newModel =
              case model of
                Loaded model_ ->
                  Loaded
                    { model_
                    | list = model_.list ++ rest.rest
                    , page = 2
                    }
                _ ->
                  model
            cmd =
              Cmd.map Types.DeferMsg deferCmd
          in
            ( newModel, cmd, socket, newDefer )

        Err error ->
          let _ = Debug.log "ReceiveRest" error
          in ( model, Cmd.none, socket, defer )

    NoOp ->
      ( model, Cmd.none, socket, defer )



subscriptions : Types.Model -> Sub Photo.Types.Msg
subscriptions model =
  Sub.none


fetch : Photo.Types.Model -> IDSocket
     -> Defer.Model -> String
     -> (JE.Value -> Photo.Types.Msg)
     -> ( Photo.Types.Model
        , Cmd Types.Msg
        , IDSocket
        , Defer.Model
        )
fetch model socket defer messageStr photoMsg =
  let
    ( cmd, newSocket ) =
      pushMsg messageStr "instagram" socket
        (\a -> Types.PhotoMsg <| photoMsg a)
  in
    ( model, cmd, newSocket, defer )
