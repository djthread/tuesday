module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
  = HomeRoute
  | ShowsRoute
  | EpisodesRoute Int
  | EventsRoute Int
  | AboutRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map ShowsRoute (s "shows")
    , map (EpisodesRoute 1) (s "episodes")
    , map EpisodesRoute (s "episodes" </> int)
    , map (EventsRoute 1) (s "events")
    , map EventsRoute (s "events" </> int)
    , map AboutRoute (s "about")
    ]


parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute


showUrl : String -> String
showUrl slug =
  "#shows/" ++ slug


episodesPageUrl : Int -> String
episodesPageUrl page =
  "#episodes/" ++ (toString page)


eventsPageUrl : Int -> String
eventsPageUrl page =
  "#events/" ++ (toString page)
