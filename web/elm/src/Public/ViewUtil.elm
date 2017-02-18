module ViewUtil exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Html.Events exposing (onWithOptions, defaultOptions)
import Json.Decode
import Types exposing (..)


myOnClick : Msg -> Attribute Msg
myOnClick msg =
  let options =
    { defaultOptions
    | preventDefault = True
    }
  in
    onWithOptions "click" options (Json.Decode.succeed msg)


toggle : Bool -> Attribute msg
toggle bool =
  let display =
    case bool of
      True  -> "block"
      False -> "none"
  in
    style [("display", display)]
