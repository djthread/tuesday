module Types exposing (..)

import Navigation exposing (Location)
import Chat.Types exposing (..)
import Routing

type alias Model =
  { route : Routing.Route
  , chat  : Chat.Types.Model
  }

type Msg
  = OnLocationChange Location
  | VideoActivated String
  -- | PlayersMsg Players.Messages.Msg
  -- | ShowAbout
