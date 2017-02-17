module Types exposing (..)

import Navigation exposing (Location)
import Chat.Types exposing (..)
import Dock.Types exposing (..)
import Routing

type alias Model =
  { route : Routing.Route
  , chat  : Chat.Types.Model
  , dock  : Dock.Types.Model
  , video : VideoModel
  }

type alias VideoModel =
  Bool

type Msg
  = OnLocationChange Location
  | PlayPodcast String String
  -- | VideoActivated String
  -- | PlayersMsg Players.Messages.Msg
  -- | ShowAbout
