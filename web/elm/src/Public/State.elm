module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation)
import Types exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute = parseLocation location
  in
    ( { route = currentRoute
      , chat  = {}
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
