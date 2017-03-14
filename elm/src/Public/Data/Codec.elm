module Data.Codec exposing (..)

import Json.Decode exposing (Decoder, at, list, int, string, succeed)
import Json.Decode.Extra exposing (date, (|:))
import Data.Types exposing (..)
import TypeUtil exposing (Pager)


showsDecoder : Decoder (List Show)
showsDecoder =
  at ["shows"] (list showDecoder)

showDecoder : Decoder Show
showDecoder =
  succeed
    Show
    |: (at ["id"] int)
    |: (at ["name"] string)
    |: (at ["slug"] string)
    |: (at ["tiny_info"] string)


showDetailDecoder : Decoder ShowDetail
showDetailDecoder =
  succeed
    ShowDetail
    |: (at ["short_info"] string)
    |: (at ["full_info"] string)


eventPagerDecoder : Decoder EventListing
eventPagerDecoder =
  succeed
    EventListing
    |: (at ["entries"] (list eventDecoder))
    |: (at ["pager"] pagerDecoder)
    

episodePagerDecoder : Decoder EpisodeListing
episodePagerDecoder =
  succeed
    EpisodeListing
    |: (at ["entries"] (list episodeDecoder))
    |: (at ["pager"] pagerDecoder)
    

pagerDecoder : Decoder Pager
pagerDecoder =
  succeed
    Pager
    |: (at ["page_number"] int)
    |: (at ["page_size"] int)
    |: (at ["total_pages"] int)
    |: (at ["total_entries"] int)

-- newStuffDecoder : Decoder NewStuff
-- newStuffDecoder =
--   succeed
--     NewStuff
--     |: (at ["events"] (list eventDecoder))
--     |: (at ["episodes"] (list episodeDecoder))

-- type alias Event =
--   { id           : Int
--   , title        : String
--   -- , showslug     : String
--   , happens_on   : Date
--   , description  : String
--   , performances : List Performance
--   }
--
-- type alias Episode =
--   { id          : Int
--   , number      : String
--   , pageUrl     : String
--   , title       : String
--   , downloadUrl : String
--   , showUrl     : String
--   , description : String
--   , record_date : Date
--   , posted_on   : Date
--   }
eventDecoder : Decoder Event
eventDecoder =
  succeed
    Event
    |: (at ["id"] int)
    |: (at ["show_id"] int)
    |: (at ["title"] string)
    |: (at ["happens_on"] date)
    |: (at ["description"] string)
    |: (at ["performances"] (list performanceDecoder))


performanceDecoder : Decoder Performance
performanceDecoder =
  succeed
    Performance
    |: (at ["time"] string)
    |: (at ["artist"] string)
    |: (at ["genres"] string)
    |: (at ["affiliations"] string)
    |: (at ["extra"] string)

episodeDecoder : Decoder Episode
episodeDecoder =
  succeed
    Episode
    |: (at ["id"] int)
    |: (at ["number"] int)
    |: (at ["title"] string)
    |: (at ["record_date"] date)
    |: (at ["posted_on"] date)
    |: (at ["filename"] string)
    |: (at ["description"] string)
    |: (at ["show_id"] int)
    |: (at ["bytes"] int)

    -- %{id:          episode.id,
    --   number:      episode.number,
    --   title:       episode.title,
    --   record_date: episode.record_date,
    --   posted_on:   episode.inserted_at |> iso8601,
    --   filename:    episode.filename,
    --   description: episode.description,
    --   show_id:     episode.show_id,
    --   bytes:       bytes_by_slug_and_filename(episode)

-- title = "Episode 22",
-- show_id = 3,
-- info_json = "{\"lines\":[{\"time\":\"8pm\",\"artist\":\"DJ Pure®\",\"genres\":\"\",\"affiliations\":\"Sucker Punch! Productions ~ Detroit Deep Sessions \",\"extra\":\" \\n\\nhttps://soundcloud.com/djpure-1\\nhttps://www.facebook.com/DjayPure\\nhttp://www.mixcloud.com/DjPure\"},{\"time\":\"7pm\",\"artist\":\"Pardeeboi\",\"genres\":\"Dnb/Bass House/Deephouse\",\"affiliations\":\"Impulse detroit/Wobblehead Radio\",\"extra\":\"https://m.soundcloud.com/lawrence-pardee\\nhttps://m.facebook.com/PardeeBoi/?ref=bookmarks\\n\"},{\"time\":\"6pm\",\"artist\":\"Dissonance\",\"genres\":\"Dub/Riddim/Grime\",\"affiliations\":\"\",\"extra\":\"https://m.soundcloud.com/dissonanceofficial\"}]}",
-- id = 87,
-- happens_on = "2017-03-10",
-- description = null

-- newMsgDecoder : Decoder Line
-- newMsgDecoder =
--   decode Line
--     |> required "stamp" date
--     |> required "user" string
--     |> required "body" string
