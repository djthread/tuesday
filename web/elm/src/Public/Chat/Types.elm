module Chat.Types exposing (..)

import Json.Encode as JE
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

type Msg
  = ReceiveNewMsg JE.Value
  | InputUser String
  | InputMsg String
  | Shout
  | OnKeyPress Int
  | NoOp
