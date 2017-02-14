module Dock.Types exposing (..)


type alias Model =
  { track : Maybe Track
  }

type alias Track =
  { src   : String
  , title : String
  }
