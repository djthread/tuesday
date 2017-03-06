module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
  = HomeRoute
  | EpisodesRoute Int
  | AboutRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map (EpisodesRoute 1) (s "episodes")
    , map EpisodesRoute (s "episodes" </> int)
    -- , map Events (s "events")
    , map AboutRoute (s "info")
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute

episodesUrl : Int -> String
episodesUrl page =
  "#episodes/" ++ (toString page)
