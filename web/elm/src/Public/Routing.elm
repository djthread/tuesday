module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
  = HomeRoute
  | LiveRoute
  | AboutRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map LiveRoute (s "live")
    , map AboutRoute (s "about")
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute
