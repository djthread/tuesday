port module Port exposing (..)


port activateVideo : String -> Cmd msg
-- port videoActivated : (String -> msg) -> Sub msg

port playEpisode : String -> Cmd msg
-- port playEpisode : (String -> msg) -> Sub msg

port init : String -> Cmd msg
