module Photo.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import TypeUtil exposing (RemoteData(..))
import Photo.Types exposing (..)
import Photo.Codec exposing (photoListDecoder)
-- import Port
import Json.Decode exposing (decodeValue)
import Json.Encode as JE
-- import Dom.Scroll
-- import Task
import StateUtil exposing (pushMessage)
-- import Phoenix.Push

init : Model
init =
  NotAsked

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
  case msg of
    ReceiveLastFour raw ->
      case decodeValue photoListDecoder raw of
        Ok list ->
          ( Loaded { list = list, page = 1 }
          , Cmd.none
          , idSocket
          )
        Err error ->
          ( model, Cmd.none, idSocket )

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
