module Chat.Codec exposing (newMsgDecoder)

import Json.Decode exposing (Decoder, at, map3, string)
import Json.Decode.Extra exposing (date)
import Chat.Types exposing (Line)


newMsgDecoder : Decoder Line
newMsgDecoder =
  map3
    Line
    (at ["stamp"] date)
    (at ["nick"] string)
    (at ["body"] string)
