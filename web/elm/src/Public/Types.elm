module Types exposing (..)

import Navigation exposing (Location)
import Chat.Types exposing (..)
import Dock.Types exposing (..)
import Routing

type alias Model =
  { route : Routing.Route
  , chat  : Chat.Types.Model
  , dock  : Dock.Types.Model
  }

type Msg
  = OnLocationChange Location
  | VideoActivated String
  | PlayPodcast String String
  -- | PlayersMsg Players.Messages.Msg
  -- | ShowAbout
