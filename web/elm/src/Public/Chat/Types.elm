module Chat.Types exposing (..)

import Date exposing (Date)

type alias Line =
  { stamp : Date
  , user  : String
  , body  : String
  }

type alias Model =
  { name  : String
  , msg   : String
  , lines : Maybe (List Line)
  }

-- type Msg
--   = Shout
--   | AppendLine Line
--   | Reset
