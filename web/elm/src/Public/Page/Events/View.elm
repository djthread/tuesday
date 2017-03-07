module Page.Events.View exposing (root)

import Data.EventListView
import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil

root : Model -> ( Crumbs, List (Html Msg) )
root model =
  let
    conf =
      { paginate = True, only = Nothing }
    listing =
      Data.EventListView.root
        conf
        model.data.shows
        model.data.events
    thecrumbs =
      case model.data.events of
        Loaded data -> crumbs data.pager.pageNumber
        _           -> crumbs 1
  in
    ( thecrumbs, listing )


crumbs : Int -> Crumbs
crumbs page =
  if page == 1 then [("Events", "")] else
    [ ("Events", "#events")
    , ("Page " ++ toString page, "")
    ]
