module View exposing (root)

import Html exposing (Html, div, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Routing exposing (Route(..))
import Page.Home.View
import Page.Shows.View
import Page.Show.View
import Page.Episodes.View
import Page.Events.View
import Page.Episode.View
import Page.Event.View
import Page.About.View
import Page.NotFound.View
import Layout
import ViewUtil


type alias Conf =
  { classes : String
  , crumbs  : Bool
  }


root : Model -> Html Msg
root model =
    render model
    |> Layout.root model


render : Model -> Html Msg
render model =
  case model.route of
    HomeRoute ->
      d (Conf "page-home" False)
        (Page.Home.View.root model)

    ShowsRoute ->
      d (Conf "page page-shows" True)
        (Page.Shows.View.root model)

    ShowRoute slug ->
      d (Conf "page page-show" True)
        (Page.Show.View.root slug model)

    EpisodesRoute page ->
      d (Conf "page page-episodes" True)
        (Page.Episodes.View.root model "" page)

    EventsRoute page ->
      d (Conf "page page-events" True)
        (Page.Events.View.root model "" page)

    ShowEpisodesRoute slug page ->
      d (Conf "page page-episodes" True)
        (Page.Episodes.View.root model slug page)

    ShowEventsRoute slug page ->
      d (Conf "page page-events" True)
        (Page.Events.View.root model slug page)

    EventRoute slug evSlug ->
      d (Conf "page page-event" True)
        (Page.Event.View.root model slug evSlug)

    EpisodeRoute slug epSlug ->
      d (Conf "page page-event" True)
        (Page.Episode.View.root model slug epSlug)

    AboutRoute ->
      d (Conf "page page-about" True)
        (Page.About.View.root model)

    NotFoundRoute ->
      d (Conf "Page page-notfound" False)
        (Page.NotFound.View.root model)

    LegacyPodcastRoute _ _ ->
      d (Conf "Page page-notfound" False)
        (Page.NotFound.View.root model)

d : Conf -> ( Crumbs, List (Html Msg) ) -> Html Msg
d conf ( crumbs, list ) =
  let
    thecrumbs =
      case conf.crumbs of
        True  -> ViewUtil.breadcrumber crumbs
        False -> []
  in
    div [ class conf.classes ] (thecrumbs ++ list)
