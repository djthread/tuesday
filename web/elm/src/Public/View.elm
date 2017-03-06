module View exposing (root)

import Html exposing (Html, div, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Routing exposing (Route(..))
import Page.Home.View
import Page.Episodes.View
import Page.About.View
import Page.NotFound.View


root : Model -> Html Msg
root model =
  case model.route of
    HomeRoute ->
      Page.Home.View.root model

    EpisodesRoute page ->
      Page.Episodes.View.root model

    AboutRoute ->
      Page.About.View.root model

    NotFoundRoute ->
      Page.NotFound.View.root model
