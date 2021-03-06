module Data.Types exposing (..)

import TypeUtil exposing (RemoteData(Loaded), Pager)
import Date exposing (Date)
import Json.Encode as JE

type Msg
  = ReceiveShows JE.Value
  | FetchNewStuff
  | FetchShowDetail String
  | FetchEpisodes Int
  | FetchShowEpisodes String Int
  | FetchEvents Int
  | FetchShowEvents String Int
  | FetchEvent String String
  | FetchEpisode String String
  | ReceiveEpisodes JE.Value
  | ReceiveEvents JE.Value
  | ReceiveShowDetail JE.Value
  | ReceiveEvent JE.Value
  | ReceiveEpisode JE.Value
  | SocketInitialized
  | NoOp

type alias Model =
  { shows      : RemoteData (List Show)
  , showDetail : RemoteData ShowDetail
  , events     : RemoteData EventListing
  , episodes   : RemoteData EpisodeListing
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
  { id        : Int
  , name      : String
  , slug      : Slug
  , tinyInfo  : String
  }

type alias Shows =
  List Show

type alias Slug =
  String

type alias ShowDetail =
  { shortInfo : String
  , fullInfo  : String
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
  { paginate  : Bool
  , show      : Maybe Show
  , only      : Maybe Int
  , linkTitle : Bool
  }


findShow : List Show -> Int -> Maybe Show
findShow shows show_id =
  let
    maybeOne =
      List.filter (\s -> s.id == show_id) shows
  in
    List.head maybeOne


findShowFromRDList : RemoteData (List Show) -> Int -> Maybe Show
findShowFromRDList rdShows show_id =
  case rdShows of
    Loaded shows ->
      findShow shows show_id
    _ ->
      Nothing


findShowBySlug : List Show -> String -> Maybe Show
findShowBySlug shows slug =
  let
    maybeOne =
      List.filter (\s -> s.slug == slug) shows
  in
    List.head maybeOne


doShowThingOr : RemoteData Shows
             -> a -> (Show -> a) -> Slug
             -> a
doShowThingOr rdShows sadVal happyFn slug =
  case rdShows of
    Loaded shows ->
      case findShowBySlug shows slug of
        Just show ->
          happyFn show
        _ -> sadVal
    _ -> sadVal
