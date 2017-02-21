module Types exposing (..)

import Phoenix.Socket
import Navigation exposing (Location)
import Chat.Types exposing (..)
import Routing

type Msg
  = OnLocationChange Location
  | ChatMsg Chat.Types.Msg
  | EnableVideo
  | PlayEpisode String String
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | NoOp

type alias Model =
  { route     : Routing.Route
  , phxSocket : Phoenix.Socket.Socket Msg
  , chat      : Chat.Types.Model
  , player    : PlayerModel
  , video     : VideoModel
  }

type alias PlayerModel =
  { track : Maybe Track
  }

type alias Track =
  { src   : String
  , title : String
  }

type alias VideoModel =
  Bool
