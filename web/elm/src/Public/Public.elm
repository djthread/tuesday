module Public exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RouteUrl exposing (UrlChange)
import Navigation
-- import Html.Events
import State exposing (..)
import Types exposing (..)
import View exposing (root)


-- MAIN

-- main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init          = State.init
    , update        = State.update
    , subscriptions = State.subscriptions
    , view          = View.root
    }

-- main =
--   Html.text "Sap!"
