module Page.Show.View exposing (root)

import Html exposing (Html, h2, h3, h4, div, text, p, a, figure, img)
-- import Html.Attributes exposing (class, href, src)
import Types exposing (..)
import Data.Types exposing (Show, findShowBySlug)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil exposing (waiting)


root : String -> Model -> ( Crumbs, List (Html Msg) )
root slug model =
  let
    ( crumbs, msgs ) =
      case model.data.shows of
        Loaded shows ->
          let
            crumbs =
              case findShowBySlug shows slug of
                Nothing   -> []
                Just show -> [ ( show.name, "" ) ]
          in
            ( crumbs, [] )
        _ ->
          ( [], [ waiting ] )
  in
    ( crumbs, msgs )



