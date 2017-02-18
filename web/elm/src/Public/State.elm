module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation, Route, Route(..))
import Types exposing (..)
import Navigation exposing (Location, newUrl)
import Port exposing (activateVideo, playEpisode)
import Dock.Types
import Task


init : Location -> ( Model, Cmd Msg )
init location =
  let
    route = parseLocation location
    cmd   = initCmd route
  in
    ( { route = route
      , chat  = {}
      , dock  = { track = Nothing }
      , video = False
      }
    , cmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        route_ = parseLocation location 
        cmd    = initCmd route_
      in
        ( { model | route = route_ }, cmd )

    EnableVideo ->
      ( { model | video = True }
      , Debug.log "sap" (activateVideo "yeap")
      )

    PlayEpisode url title ->
      let
        dock  = model.dock
        track = Dock.Types.Track url title
      in
        ( { model
          | dock =
              { dock | track = Just track }
          }
        , playEpisode "go beach"
        )


subscriptions : Model -> Sub Msg
subscriptions model =
  -- videoActivated VideoActivated
  Sub.none


initCmd : Route -> Cmd Msg
initCmd route =
  case route of
    _ ->
      Cmd.none
