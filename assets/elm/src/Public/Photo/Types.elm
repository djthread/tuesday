module Photo.Types exposing (..)

import Json.Encode as JE
import Date exposing (Date)
import TypeUtil exposing (RemoteData)

type Msg
  = FetchLastFour
  | ReceiveLastFour JE.Value
  | ShowNextFour
  | ReceiveRest JE.Value
  | NoOp

type alias Model =
  RemoteData Photos

type alias Photos =
  { list  : List Photo
  , page  : Int
  , total : Int
  }

type alias Photo =
  { created  : Date
  , caption  : String
  , link     : String
  , full_url : String
  , thumb    : Image
  }

type alias Image =
  { url    : String
  , width  : Int
  , height : Int
  }

type alias LastFour =
  { last_four : List Photo
  , total     : Int
  }

type alias Rest =
  { rest : List Photo
  }
