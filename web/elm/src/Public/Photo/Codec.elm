module Photo.Codec exposing (..)

import Json.Decode exposing (Decoder, at, list, int, string, succeed)
import Json.Decode.Extra exposing (date, (|:))
import Photo.Types exposing (..)
-- import TypeUtil exposing (Pager)


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
    |: (at ["thumb"] imageDecoder)
    |: (at ["low"] imageDecoder)
    |: (at ["standard"] imageDecoder)


imageDecoder : Decoder Image
imageDecoder =
  succeed
    Image
    |: (at ["url"] string)
    |: (at ["width"] int)
    |: (at ["height"] int)