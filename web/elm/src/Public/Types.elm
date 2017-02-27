module Types exposing (..)

import Phoenix.Socket
import Navigation exposing (Location)
import Chat.Types
import Data.Types
import Routing
import Defer

type Msg
  = OnLocationChange Location
  | NavigateTo String
  | DeferMsg Defer.Msg
  | ChatMsg Chat.Types.Msg
  | DataMsg Data.Types.Msg
  | EnableVideo
  | ClosePlayer
  | PlayEpisode String String
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | SocketInitialized
  | NoOp

type alias Model =
  { route    : Routing.Route
  , loading  : Int
  , idSocket : IDSocket
  , chat     : Chat.Types.Model
  , data     : Data.Types.Model
  , player   : PlayerModel
  , video    : VideoModel
  , defer    : Defer.Model
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

type alias IDSocket =
  Phoenix.Socket.Socket Msg
