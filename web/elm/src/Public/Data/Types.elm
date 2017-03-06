module Data.Types exposing (..)

import TypeUtil exposing (RemoteData, Pager)
import Date exposing (Date)
import Json.Encode as JE

type Msg
  = ReceiveShows JE.Value
  | FetchNewStuff
  | FetchEpisodePage Int
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

-- 1 = {
-- tiny_info = "Lawrence PardeeBoi and Sinister Dosage host *WobbleHead Radio*... Banging them beats every other friday, 6pm till 9pm eastern time!!",
-- slug = "wobblehead-radio",
-- name = "WobbleHead Radio",
-- id = 3,
-- events = {
--
-- 0 = {
-- title = "Episode 22",
-- show_id = 3,
-- info_json = "{\"lines\":[{\"time\":\"8pm\",\"artist\":\"DJ Pure®\",\"genres\":\"\",\"affiliations\":\"Sucker Punch! Productions ~ Detroit Deep Sessions \",\"extra\":\" \\n\\nhttps://soundcloud.com/djpure-1\\nhttps://www.facebook.com/DjayPure\\nhttp://www.mixcloud.com/DjPure\"},{\"time\":\"7pm\",\"artist\":\"Pardeeboi\",\"genres\":\"Dnb/Bass House/Deephouse\",\"affiliations\":\"Impulse detroit/Wobblehead Radio\",\"extra\":\"https://m.soundcloud.com/lawrence-pardee\\nhttps://m.facebook.com/PardeeBoi/?ref=bookmarks\\n\"},{\"time\":\"6pm\",\"artist\":\"Dissonance\",\"genres\":\"Dub/Riddim/Grime\",\"affiliations\":\"\",\"extra\":\"https://m.soundcloud.com/dissonanceofficial\"}]}",
-- id = 87,
-- happens_on = "2017-03-10",
-- description = null },
--
-- 1 = { title = "Episode 23", show_id = 3, info_json = "{\"lines\":[{\"time\":\"8pm\",\"artist\":\"DJ FIXED\",\"genres\":\"\",\"affiliations\":\"\",\"extra\":\"More info tba\"},{\"time\":\"7pm\",\"artist\":\"Emplate\",\"genres\":\"DnB\",\"affiliations\":\"(The Everyday Junglist Podcast | DNBRadio | Boss Music | In:Direct Audio | Barbaric Empire)\",\"extra\":\"Cleveland, Ohio\\n\"},{\"time\":\"6pm\",\"artist\":\"Sinister Dosage\",\"genres\":\"DnB\",\"affiliations\":\"Impulse Detroit/Strangeluv\",\"extra\":\"d•-•b\"}]}", id = 92, happens_on = "2017-03-24", description = " \n" } },
--
-- episodes = { 0 = { title = "Episode 21", show_id = 3, record_date = "2017-02-10", posted_on = "2017-02-12", number = 21, id = 72, filename = "wobblehead-021.mp3", description = "6pm ICONIAN\n\n7pm SINISTER DOSAGE\n\n8pm BLNT FOURCE", bytes = 482915264 }, 1 = { title = "Episode 20", show_id = 3, record_date = "2017-01-27", posted_on = "2017-01-29", number = 20, id = 69, filename = "wobblehead-020.mp3", description = "Lawrence PardeeBoi playing various styles of DnB for 2 1/2 hours....", bytes = 362992558 }, 2 = { title = "Episode 12", show_id = 3, record_date = "2019-09-16", posted_on = "2016-09-19", number = 12, id = 45, filename = "wobblehead-012.mp3", description = "Sinister Dosage B2B DJ Larry Bird\n\n\nHypnotic\n\n\nKristof", bytes = 396336279 } }
-- }, 
  

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
  -- , pageUrl     : String
  -- , downloadUrl : String
  -- , showUrl     : String
  }


findShow : List Show -> Int -> Maybe Show
findShow shows show_id =
  let
    maybeOne =
      List.filter (\s -> s.id == show_id) shows
  in
    List.head maybeOne
