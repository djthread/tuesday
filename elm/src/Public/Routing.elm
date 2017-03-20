module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Data.Types exposing (Show, Episode, Event)
import Regex exposing (regex, replace, HowMany(All))
import Data.Types exposing (Slug)


type Route
  = HomeRoute
  | ShowsRoute
  | ShowRoute String
  | EpisodesRedirectorRoute
  | EventsRedirectorRoute
  | EpisodesRoute Int
  | EventsRoute Int
  | ShowEpisodesRoute String Int
  | ShowEventsRoute String Int
  | ShowInfoRoute String
  | EventRoute String String
  | EpisodeRoute String String
  | AboutRoute
  | NotFoundRoute
  | ShowEpisodesRedirectorRoute String
  | ShowEventsRedirectorRoute String
  | LegacyPodcastRoute String String


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map ShowsRoute (s "shows")
    , map ShowRoute (s "shows" </> string)
    , map EpisodesRedirectorRoute (s "episodes")
    , map EpisodesRoute (s "episodes" </> int)
    , map EventsRedirectorRoute (s "events")
    , map EventsRoute (s "events" </> int)
    , map ShowEpisodesRedirectorRoute (s "shows" </> string </> s "episodes")
    , map ShowEpisodesRoute (s "shows" </> string </> s "episodes" </> int)
    , map ShowEventsRedirectorRoute (s "shows" </> string </> s "events")
    , map ShowEventsRoute (s "shows" </> string </> s "events" </> int)
    , map ShowInfoRoute (s "shows" </> string </> s "info")
    , map EpisodeRoute (s "shows" </> string </> s "episodes" </> string)
    , map EventRoute (s "shows" </> string </> s "events" </> string)
    , map AboutRoute (s "about")
    , map LegacyPodcastRoute
            (s "shows" </> string </> s "podcast" </> string)
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

showEpisodesUrl : Show -> Int -> String
showEpisodesUrl show page =
  "#shows/" ++ show.slug
    ++ "/episodes/" ++ (toString page)

maybeShowEpisodesUrl : Maybe Show -> Int -> String
maybeShowEpisodesUrl maybeShow page =
  case maybeShow of
    Just show -> showEpisodesUrl show page
    Nothing   -> episodesUrl page


eventsUrl : Int -> String
eventsUrl page =
  "#events/" ++ (toString page)

showEventsUrl : Show -> Int -> String
showEventsUrl show page =
  "#shows/" ++ show.slug
    ++ "/events/" ++ (toString page)

maybeShowEventsUrl : Maybe Show -> Int -> String
maybeShowEventsUrl maybeShow page =
  case maybeShow of
    Just show -> showEventsUrl show page
    Nothing   -> eventsUrl page


showUrl : Slug -> String
showUrl slug =
  "#shows/" ++ slug


showInfoUrl : Slug -> String
showInfoUrl slug =
  "#shows/" ++ slug ++ "/info"


episodeUrl : Show -> Episode -> String
episodeUrl show episode =
  let
    titlePart =
      slugify episode.title
    epSlug =
      (toString episode.number) ++ "-" ++ titlePart
  in
    "#shows/" ++ show.slug ++ "/episodes/" ++ epSlug


eventUrl : Show -> Event -> String
eventUrl show event =
  let
    titlePart =
      slugify event.title
    evSlug =
      (toString event.id) ++ "-" ++ titlePart
  in
    "#shows/" ++ show.slug ++ "/events/" ++ evSlug


slugify : String -> String
slugify str =
  let re = regex "[^A-Za-z0-9]+"
  in
    replace All re (\_ -> "-") str
