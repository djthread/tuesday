module Types exposing (..)

import Chat.Types exposing (..)

type alias Model =
  { chat : Chat.Types.Model
  }

type Msg =
  Athing
