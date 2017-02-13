module View exposing (root)

import Html exposing (Html, div, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Routing exposing (Route(..))
import Page.Home.View
import Page.About.View
import Page.NotFound.View


root : Model -> Html Msg
root model =
  div []
    [ page model
    , footer []
        [text "i m d footer"]
    ]

page : Model -> Html Msg
page model =
  case model.route of
    HomeRoute ->
      Page.Home.View.root model

    AboutRoute ->
      Page.About.View.root model

    NotFoundRoute ->
      Page.NotFound.View.root model
