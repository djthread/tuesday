module Page.Show.View exposing (root)

import Html exposing (Html, h2, h3, h4, div, text, p, a, figure, img)
-- import Html.Attributes exposing (class, href, src)
import Types exposing (..)
import Data.Types exposing (Show, ShowDetail, findShowBySlug)
import Data.EventsEpisodesColumnsView
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import Routing


root : String -> Model -> ( Crumbs, List (Html Msg) )
root slug model =
  case model.data.shows of
    Loaded shows ->
      case model.data.showDetail of
        Loaded showDetail ->
          case findShowBySlug shows slug of
            Just show ->
              ( [( show.name, "" )], build show model )
            _ -> waiting
        _ -> waiting
    _ -> waiting


waiting : ( Crumbs, List (Html Msg) )
waiting = ( [], [ ViewUtil.waiting ] )


build : Show -> Model -> List (Html Msg)
build show model =
  Data.EventsEpisodesColumnsView.root model.data model.player show.slug
    (Routing.showEventsUrl show 1)
    (Routing.showEpisodesUrl show 1)
