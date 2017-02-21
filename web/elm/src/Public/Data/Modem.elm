module Data.Modem exposing (..)

import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Decode.Extra exposing (date)
import Data.Types exposing (..)


newMsgDecoder : Decoder Line
newMsgDecoder =
  decode Line
    |> required "stamp" date
    |> required "user" string
    |> required "body" string
