module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation)
import Types exposing (..)
import Navigation exposing (Location, newUrl)


init : Location -> ( Model, Cmd Msg )
init location =
  ( { route = parseLocation location
    , chat  = {}
    }
  , Cmd.none
  )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    -- ShowAbout ->
    --   ( model, newUrl "#about" )
    OnLocationChange location ->
      ( { model | route = parseLocation location }
      , Cmd.none
      )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

