module Types exposing (..)

import Json.Encode as JE
import Html exposing (Html)
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
  | PlayEpisode String Data.Types.Episode
  | SocketInitialized
  | NoOp

type NavSection
  = Shows
  | Events
  | Episodes
  | About
  | None

type alias Model =
  { route    : Routing.Route
  , section  : NavSection
  , loading  : Int
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
  { src     : String
  , episode : Data.Types.Episode
  }

type alias VideoModel =
  Bool

type alias Crumbs =
  List Crumb

type alias Crumb =
  ( String,  String )


noPayload : JE.Value
noPayload = JE.string ""


wsUrl : String
wsUrl =
  "wss://impulsedetroit.net/socket/websocket"
  -- "ws://localhost:4091/socket/websocket"
