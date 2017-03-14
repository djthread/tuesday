port module Port exposing (..)


port activateVideo : String -> Cmd msg
-- port videoActivated : (String -> msg) -> Sub msg
port activateVideo2 : String -> Cmd msg

port playEpisode : String -> Cmd msg
-- port playEpisode : (String -> msg) -> Sub msg

port init : String -> Cmd msg

port getChatName : String -> Cmd msg
port gotChatName : (String -> msg) -> Sub msg
port setChatName : String -> Cmd msg

-- port loadPhotos : String -> Cmd msg
port activateLightbox : String -> Cmd msg

port setTitle : String -> Cmd msg
