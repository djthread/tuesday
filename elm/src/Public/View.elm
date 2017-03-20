module View exposing (root)

import Html exposing (Html, div, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Routing exposing (Route(..))
import Page.Home.View
import Page.Shows.View
import Page.Show.View
import Page.Show.Episodes.View
import Page.Show.Events.View
import Page.Show.Info.View
import Page.Episodes.View
import Page.Events.View
import Page.Episode.View
import Page.Event.View
import Page.About.View
import Page.NotFound.View
import Layout
import ViewUtil
import Page.Show.ViewUtil exposing (ShowScreen(..))


type alias Conf =
  { classes : String
  }


root : Model -> Html Msg
root model =
    render model
    |> Layout.root model


render : Model -> Html Msg
render model =
  case model.route of
    HomeRoute ->
      d (Conf "page-home")
        (Page.Home.View.root model)

    ShowsRoute ->
      d (Conf "page page-shows")
        (Page.Shows.View.root model)

    ShowRoute slug ->
      d (Conf "page page-show")
        (Page.Show.View.root slug model)

    EpisodesRoute page ->
      d (Conf "page page-episodes")
        (Page.Episodes.View.root model page)

    EventsRoute page ->
      d (Conf "page page-events")
        (Page.Events.View.root model page)

    ShowEpisodesRoute slug page ->
      d (Conf "page page-episodes")
        (Page.Show.Episodes.View.root model slug page)

    ShowEventsRoute slug page ->
      d (Conf "page page-events")
        (Page.Show.Events.View.root model slug page)

    ShowInfoRoute slug ->
      d (Conf "page page-info")
        (Page.Show.Info.View.root model slug)

    EventRoute slug evSlug ->
      d (Conf "page page-event")
        (Page.Event.View.root model slug evSlug)

    EpisodeRoute slug epSlug ->
      d (Conf "page page-event")
        (Page.Episode.View.root model slug epSlug)

    AboutRoute ->
      d (Conf "page page-about")
        (Page.About.View.root model)

    NotFoundRoute ->
      d (Conf "Page page-notfound")
        (Page.NotFound.View.root model)

    LegacyPodcastRoute _ _ ->
      d (Conf "Page page-notfound")
        (Page.NotFound.View.root model)

    _ ->
      d (Conf "") ( [], [] )


d : Conf -> ( Crumbs, List (Html Msg) )
 -> Html Msg
d conf ( crumbs, list ) =
  let
    thecrumbs =
      ViewUtil.breadcrumber crumbs
  in
    div [ class conf.classes ] (thecrumbs ++ list)
