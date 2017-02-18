module Chat.State exposing (init, update, subscriptions)

-- import Routing exposing (parseLocation, Route, Route(..))
-- import Navigation exposing (Location, newUrl)
-- import Port exposing (activateVideo, playEpisode)
-- import Dock.Types
import Types exposing (..)
import Chat.Types exposing (ReceiveNewMsg, Line)
import Chat.Modem exposing (newMsgDecoder)
import Json.Decode exposing (decodeValue)
-- import Json.Decode.Extra exposing (Time)
import Time expoling (Time)

init : Location -> ( Model, Cmd Msg )
init location =
  ( Chat.Types.Model "" "" Nothing
  , Cmd.none
  )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Shout msg ->
      ( model
      , Cmd.none



subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
