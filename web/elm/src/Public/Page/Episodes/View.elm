module Page.Episodes.View exposing (root)

import Data.EpisodeListView
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
      Data.EpisodeListView.root
        conf
        model.player
        model.data.shows
        model.data.episodes
    thecrumbs =
      case model.data.episodes of
        Loaded data -> crumbs data.pager.pageNumber
        _           -> crumbs 1
  in
    ( thecrumbs, listing )


crumbs : Int -> Crumbs
crumbs page =
  if page == 1 then [("Episodes", "")] else
    [ ("Episodes", "#episodes")
    , ("Page " ++ toString page, "")
    ]
