module Data.Types exposing (..)

import TypeUtil exposing (RemoteData)
import Date exposing (Date)
import Json.Encode as JE

type Msg
  = ReceiveShows JE.Value
  | SocketInitialized
  | NoOp

type alias Model =
  { shows          : RemoteData (List Show)

    -- home page data, cached
  , upcomingEvents : RemoteData (List Event)
  , recentEpisodes : RemoteData (List Episode)

    -- whatever is listed on the current page
  , viewedEvents   : RemoteData (List Event)
  , viewedEpisodes : RemoteData (List Episode)
  }

type alias Show =
  { id       : Int
  , name     : String
  , slug     : String
  , tinyInfo : String
  }

type alias Performance =
  { time         : String
  , artist       : String
  , genres       : String
  , affiliations : String
  }

type alias Event =
  { title        : String
  , showslug     : String
  , happens_on   : Date
  , description  : String
  , performances : List Performance
  }

type alias Episode =
  { number      : String
  , pageUrl     : String
  , title       : String
  , downloadUrl : String
  , showUrl     : String
  , description : String
  , record_date : Date
  , posted_on   : Date
  }
