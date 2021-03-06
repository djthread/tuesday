module Photo.Codec exposing (..)

import Json.Decode exposing (Decoder, at, list, int, string, succeed)
import Json.Decode.Extra exposing (date, (|:))
import Photo.Types exposing (..)
-- import TypeUtil exposing (Pager)


lastFourDecoder : Decoder LastFour
lastFourDecoder =
  succeed
    LastFour
    |: (at ["last_four"] photoListDecoder)
    |: (at ["total"] int)


restListDecoder : Decoder Rest
restListDecoder =
  succeed
    Rest
    |: (at ["rest"] photoListDecoder)


photoListDecoder : Decoder (List Photo)
photoListDecoder =
  list photoDecoder


photoDecoder : Decoder Photo
photoDecoder =
  succeed
    Photo
    |: (at ["created"] date)
    |: (at ["caption"] string)
    |: (at ["link"] string)
    |: (at ["full_url"] string)
    |: (at ["thumb"] imageDecoder)


imageDecoder : Decoder Image
imageDecoder =
  succeed
    Image
    |: (at ["url"] string)
    |: (at ["width"] int)
    |: (at ["height"] int)
