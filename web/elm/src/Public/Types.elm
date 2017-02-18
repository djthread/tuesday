module Types exposing (..)

import Json.Encode as JE
import Phoenix.Socket
import Navigation exposing (Location)
import Chat.Types exposing (..)
import Dock.Types exposing (..)
import Routing

type alias Model =
  { route     : Routing.Route
  , phxSocket : Phoenix.Socket.Socket Msg
  , chat      : Chat.Types.Model
  , dock      : Dock.Types.Model
  , video     : VideoModel
  }

type alias VideoModel =
  Bool

type Msg
  = OnLocationChange Location
  -- | ChatMsg (Chat.Types.Msg Msg)
  | EnableVideo
  | PlayEpisode String String
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | ReceiveNewMsg JE.Value
  | InputUser String
  | InputMsg String
  | NoOp
  -- | ActuallyPlayEpisode String String
  -- | VideoActivated String
  -- | PlayersMsg Players.Messages.Msg
  -- | ShowAbout
