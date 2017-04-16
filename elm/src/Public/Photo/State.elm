module Photo.State exposing (init, update, subscriptions)

import Types exposing (Msg(DeferMsg))
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

update : Photo.Types.Msg -> Photo.Types.Model
      -> Defer.Model
      -> ( Photo.Types.Model
         , Cmd Types.Msg
         , Defer.Model
         )
update msg model defer =
  case msg of
    FetchLastFour ->
      fetch model defer "last_four" ReceiveLastFour

    ShowNextFour ->
      case model of
        Loaded model_ ->
          if (List.length model_.list) == 4 then
            fetch model defer "rest" ReceiveRest
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
              , defer
              )
        _ ->
          ( model, Cmd.none, defer )

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
            , newDefer
            )

        Err error ->
          let _ = Debug.log "ReceiveLastFour Error" error
          in ( model, Cmd.none, defer )

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
            ( newModel, cmd, newDefer )

        Err error ->
          let _ = Debug.log "ReceiveRest" error
          in ( model, Cmd.none, defer )

    NoOp ->
      ( model, Cmd.none, defer )



subscriptions : Types.Model -> Sub Photo.Types.Msg
subscriptions model =
  Sub.none


fetch : Photo.Types.Model
     -> Defer.Model -> String
     -> (JE.Value -> Photo.Types.Msg)
     -> ( Photo.Types.Model
        , Cmd Types.Msg
        , Defer.Model
        )
fetch model defer messageStr photoMsg =
  let
    cmd =
      pushMsg messageStr "instagram"
        (\a -> Types.PhotoMsg <| photoMsg a)
  in
    ( model, cmd, defer )
