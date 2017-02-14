module State exposing (init, update, subscriptions)

import Routing exposing (parseLocation)
import Types exposing (..)
import Navigation exposing (Location, newUrl)
import Port exposing (activateVideo, playEpisode)
import Dock.Types


init : Location -> ( Model, Cmd Msg )
init location =
  ( { route = parseLocation location
    , chat = {}
    , dock = { track = Nothing }
    }
  -- , PlayPodcast "https://impulsedetroit.net/download/techno-tuesday/techtues-102.mp3" "TT 102"
  -- , Cmd.none
  , activateVideo "do eet"
  )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      ( { model | route = parseLocation location }
      , Cmd.none
      )

    -- VideoActivated msg ->
    --   ( model, Cmd.none )

    PlayPodcast url title ->
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
