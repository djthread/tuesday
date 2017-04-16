module Public exposing (main)

import RouteUrl exposing (UrlChange)
import Navigation
import State
import View
import Types exposing (Model, Msg(OnLocationChange))


main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init          = State.init
    , update        = State.update
    , subscriptions = State.subscriptions
    , view          = View.root
    }
