module Data.State exposing (init, update, subscriptions)

import Types exposing (IDSocket)
import Data.Types exposing (..)
import Data.Modem exposing (..)
import StateUtil exposing (pushMessage)
-- import Port
import Json.Decode exposing (decodeValue)
-- import Json.Encode as JE
-- import Task

init : ( Model, Cmd Types.Msg )
init =
  ( { upcomingEvents : Nothing
    , recentEpisodes : Nothing
    , viewedEvents   : Nothing
    , viewedEpisodes : Nothing
    }
  , pushMessage "shows" "site" payload idSocket
  )

update : Msg -> Model -> IDSocket
      -> ( Model, Cmd Types.Msg, IDSocket )
update msg model idSocket =
  case msg of
    ReceiveShows raw ->
      case decodeValue showsDecoder raw of
        OK shows ->
          shows
            |> Debug.log
          ( model, Cmd.none, idSocket )

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



pushFetchMessage : Model -> IDSocket
                -> ( Model, Cmd Types.Msg, IDSocket )
pushFetchMessage model idSocket =
  let
    -- payload =
    --   JE.object
    --     [ ( "user", JE.string model.name )
    --     , ( "body", JE.string model.msg )
    --     ]
    ( newSocket, cmd ) =
      pushMessage "new:msg" "rooms:lobby" payload idSocket
  in
    ( model
    , cmd
    , newSocket
    )
