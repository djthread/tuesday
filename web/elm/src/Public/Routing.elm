module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
  = HomeRoute
  | EpisodesRoute Int
  | EventsRoute Int
  | AboutRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map (EpisodesRoute 1) (s "episodes")
    , map EpisodesRoute (s "episodes" </> int)
    , map (EventsRoute 1) (s "events")
    , map EventsRoute (s "events" </> int)
    , map AboutRoute (s "info")
    ]


parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute


episodesPageUrl : Int -> String
episodesPageUrl page =
  "#episodes/" ++ (toString page)


eventsPageUrl : Int -> String
eventsPageUrl page =
  "#events/" ++ (toString page)
