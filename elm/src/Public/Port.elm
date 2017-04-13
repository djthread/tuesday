port module Port exposing (..)


port activateVideo : String -> Cmd msg
-- port videoActivated : (String -> msg) -> Sub msg
port activateVideo2 : String -> Cmd msg

port playEpisode : String -> Cmd msg
-- port playEpisode : (String -> msg) -> Sub msg

port init : String -> Cmd msg

port getChatNick : String -> Cmd msg
port gotChatNick : (String -> msg) -> Sub msg
port setChatNick : String -> Cmd msg

-- port loadPhotos : String -> Cmd msg
port activateLightbox : String -> Cmd msg

port setTitle : String -> Cmd msg
