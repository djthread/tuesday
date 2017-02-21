module Types exposing (..)

import Phoenix.Socket
import Navigation exposing (Location)
import Chat.Types
import Data.Types
import Routing
import RemoteData exposing (RemoteData)

type Msg
  = OnLocationChange Location
  | ChatMsg Chat.Types.Msg
  | DataMsg Data.Types.Msg
  | EnableVideo
  | PlayEpisode String String
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | NoOp

type alias Model =
  { route    : Routing.Route
  , loading  : Bool
  , idSocket : IDSocket
  , chat     : Chat.Types.Model
  , data     : Data.Types.Model
  , player   : PlayerModel
  , video    : VideoModel
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
