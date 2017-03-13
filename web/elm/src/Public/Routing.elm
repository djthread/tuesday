module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Data.Types exposing (Show)


type Route
  = HomeRoute
  | ShowsRoute
  | ShowRoute String
  | EpisodesRoute Int
  | EventsRoute Int
  | ShowEpisodesRoute String Int
  | ShowEventsRoute String Int
  | AboutRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map ShowsRoute (s "shows")
    , map ShowRoute (s "shows" </> string)
    , map (EpisodesRoute 1) (s "episodes")
    , map EpisodesRoute (s "episodes" </> int)
    , map (EventsRoute 1) (s "events")
    , map EventsRoute (s "events" </> int)
    , map ShowEpisodesRoute (s "shows" </> string </> s "episodes" </> int)
    , map ShowEventsRoute (s "shows" </> string </> s "events" </> int)
    , map AboutRoute (s "about")
    ]


parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute


episodesUrl : Maybe Show -> Int -> String
episodesUrl maybeShow page =
  case maybeShow of
    Just show ->
      "#shows/" ++ show.slug
        ++ "/episodes/" ++ (toString page)
    Nothing ->
      "#episodes/" ++ (toString page)


eventsUrl : Maybe Show -> Int -> String
eventsUrl maybeShow page =
  case maybeShow of
    Just show ->
      "#shows/" ++ show.slug
        ++ "/events/" ++ (toString page)
    Nothing ->
      "#events/" ++ (toString page)


showUrl : String -> String
showUrl slug =
  "#shows/" ++ slug
