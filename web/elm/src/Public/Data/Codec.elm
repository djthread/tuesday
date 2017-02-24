module Data.Codec exposing (..)

import Json.Decode exposing (Decoder, at, map4, list, int, string)
import Json.Decode.Extra exposing (date)
import Data.Types exposing (..)


showsDecoder : Decoder (List Show)
showsDecoder =
  at ["shows"] (list showDecoder)

showDecoder : Decoder Show
showDecoder =
  map4
    Show
    (at ["id"] int)
    (at ["name"] string)
    (at ["slug"] string)
    (at ["tinyInfo"] string)


-- newMsgDecoder : Decoder Line
-- newMsgDecoder =
--   decode Line
--     |> required "stamp" date
--     |> required "user" string
--     |> required "body" string
