module Page.Home.State exposing (init)

import Types exposing (Msg, DataMsg)
import Data.Types

init : Data.Types.Model -> ( Data.Types.Model, Cmd Msg )
init model =
  ( model
  , DataMsg Data.Types.FetchNewStuff
  )
