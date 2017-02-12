module Public exposing (main)

import Html exposing (Html)
import State exposing (..)
import Types exposing (..)
import View exposing (root)


-- MAIN

main : Program Never Model Msg
main =
  Html.program
    { init          = State.init
    , update        = State.update
    , subscriptions = State.subscriptions
    , view          = View.root
    }

-- main =
--   Html.text "Sap!"
