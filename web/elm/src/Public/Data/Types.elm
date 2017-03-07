module Data.Types exposing (..)

import TypeUtil exposing (RemoteData, Pager)
import Date exposing (Date)
import Json.Encode as JE

type Msg
  = ReceiveShows JE.Value
  | FetchNewStuff
  | FetchEpisodes Int
  | FetchEvents Int
  | ReceiveEpisodes JE.Value
  | ReceiveEvents JE.Value
  | SocketInitialized
  | NoOp

type alias Model =
  { shows    : RemoteData (List Show)
  , events   : RemoteData EventListing
  , episodes : RemoteData EpisodeListing
  }

type alias EventListing =
  { entries : List Event
  , pager   : Pager
  }

type alias EpisodeListing =
  { entries : List Episode
  , pager   : Pager
  }

type alias Show =
  { id       : Int
  , name     : String
  , slug     : String
  , tinyInfo : String
  }

type alias NewStuff =
  { events   : List Event
  , episodes : List Episode
  }

type alias Performance =
  { time         : String
  , artist       : String
  , genres       : String
  , affiliations : String
  , extra        : String
  }

type alias Event =
  { id           : Int
  , show_id      : Int
  , title        : String
  -- , showslug     : String
  , happens_on   : Date
  , description  : String
  , performances : List Performance
  }

type alias Episode =
  { id          : Int
  , number      : Int
  , title       : String
  , record_date : Date
  , posted_on   : Date
  , filename    : String
  , description : String
  , show_id     : Int
  , bytes       : Int
  }

type alias ListConfig =
  { paginate : Bool
  , only     : Maybe Int
  }


findShow : List Show -> Int -> Maybe Show
findShow shows show_id =
  let
    maybeOne =
      List.filter (\s -> s.id == show_id) shows
  in
    List.head maybeOne


findShowBySlug : List Show -> String -> Maybe Show
findShowBySlug shows slug =
  let
    maybeOne =
      List.filter (\s -> s.slug == slug) shows
  in
    List.head maybeOne
