module Chat.Types exposing (..)

import Json.Encode as JE
import Date exposing (Date)

type alias Line =
  { stamp : Date
  , nick  : String
  , body  : String
  }

type alias Model =
  { nick  : String
  , msg   : String
  , lines : Maybe (List Line)
  }

type Msg
  = ReceiveNewMsg JE.Value
  | InputNick String
  | InputMsg String
  | OnKeyPress Int
  | GotChatNick String
  | NoOp
