module State exposing (..)

import Types exposing (..)

init : ( Model, Cmd Msg )
init =
  ( { chat = {} }
  , Cmd.none
  )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )
  -- case msg of

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
