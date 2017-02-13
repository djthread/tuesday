port module Port exposing (..)


port activateVideo  : String -> Cmd msg
port videoActivated : (String -> msg) -> Sub msg
