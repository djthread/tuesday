module Photo.Types exposing (..)

import Json.Encode as JE
import Date exposing (Date)
import TypeUtil exposing (RemoteData)

type Msg
  = ReceiveLastFour JE.Value
  | NoOp

  --   ReceiveNewMsg JE.Value
  -- | InputUser String
  -- | InputMsg String
  -- | OnKeyPress Int
  -- | GotChatName String
  -- | NoOp

type alias Model =
  RemoteData Photos

type alias Photos =
  { list : List Photo
  , page : Int
  }

type alias Photo =
  { created   : Date
  , caption   : String
  , link      : String
  , thumb     : Image
  , low       : Image
  , standard  : Image
  }

type alias Image =
  { url    : String
  , width  : Int
  , height : Int
  }