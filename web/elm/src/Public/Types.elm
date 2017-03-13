module Types exposing (..)

import Json.Encode as JE
import Phoenix.Socket
import Navigation exposing (Location)
import Chat.Types
import Data.Types
import Photo.Types
import Routing
import Defer

type Msg
  = OnLocationChange Location
  | NavigateTo String
  | DeferMsg Defer.Msg
  | ChatMsg Chat.Types.Msg
  | DataMsg Data.Types.Msg
  | PhotoMsg Photo.Types.Msg
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
  , photo    : Photo.Types.Model
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

type alias Crumbs =
  List Crumb

type alias Crumb =
  ( String,  String )

noPayload : JE.Value
noPayload = JE.string ""
