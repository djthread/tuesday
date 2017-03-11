module Photo.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import TypeUtil exposing (RemoteData(..))
import Photo.Types exposing (..)
import Photo.Codec exposing (lastFourDecoder)
-- import Port
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
-- import Dom.Scroll
-- import Task
import StateUtil exposing (pushMsg)
-- import Phoenix.Push

init : Model
init =
  NotAsked

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
  case Debug.log "PHOTOUPDATE" msg of
    FetchLastFour ->
      let
        ( cmd, socket ) =
          pushMsg "last_four" "instagram" idSocket
            (\a -> Types.PhotoMsg <| ReceiveLastFour a)
      in
        ( model, cmd, socket )

    ReceiveLastFour raw ->
      case decodeValue lastFourDecoder raw of
        Ok l4 ->
          ( Loaded
              { list = l4.last_four
              , total = l4.total
              , page = 1
              }
          , Cmd.none
          , idSocket
          )

        Err error ->
          let _ = Debug.log "ReceiveLastFour Error" error
          in ( model, Cmd.none, idSocket )

    -- ReceiveNewMsg raw ->
    --   case decodeValue newMsgDecoder raw of
    --     Ok line ->
    --       let
    --         lines =
    --           case model.lines of
    --             Just lines -> Just (lines ++ [line])
    --             Nothing ->    Just [line]
    --         toBottom =
    --           Dom.Scroll.toBottom "chat-messages"
    --       in
    --         ( { model | lines = lines }
    --         , Task.attempt (\_ -> Types.NoOp) toBottom
    --         , idSocket
    --         )
    --
    --     Err error ->
    --       ( model, Cmd.none, idSocket )
    --
    -- InputUser name ->
    --   ( { model | name = name }
    --   , Cmd.none
    --   , idSocket
    --   )
    --
    -- InputMsg msg ->
    --   ( { model | msg = msg }
    --   , Cmd.none
    --   , idSocket
    --   )
    --
    -- OnKeyPress int ->
    --   case int of
    --     13 ->   -- enter key
    --       pushChatMessage model idSocket
    --
    --     _ ->
    --       ( model, Cmd.none, idSocket )
    --
    -- GotChatName name ->
    --   ( { model | name = name }
    --   , Cmd.none
    --   , idSocket
    --   )

    NoOp ->
      ( model, Cmd.none, idSocket )



subscriptions : Types.Model -> Sub Msg
subscriptions model =
  Sub.none
