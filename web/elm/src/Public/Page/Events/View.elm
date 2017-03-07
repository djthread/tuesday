module Page.Events.View exposing (root)

import Data.EventListView
import Html exposing (Html, h2, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil
import Layout

root : Model -> Html Msg
root model =
  let
    conf =
      { paginate = True, only = Nothing }
    listing =
      Data.EventListView.root
        conf
        model.data.shows
        model.data.events
    ( page, pagetext ) =
        case model.data.events of
          Loaded data ->
            let page = data.pager.pageNumber
            in
              ( page 
              , ", Page " ++ (toString page)
              )
          _ -> ( 1, "" )
    titletext = 
      "Events" -- ++ pagetext
    title =
      [ h2 [] [ text titletext ] ]
    crumbs =
      ViewUtil.breadcrumber
        ( if page == 1 then [("Events", "")] else
            [ ("Events", "#events")
            , ("Page " ++ toString page, "")
            ]
        )
    content =
      div [ class "page-events" ] (crumbs ++ title ++ listing)
  in
    Layout.root model content
