module Page.About.View exposing (..)

import Html exposing (Html, div, p, a, text, footer)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Types exposing (..)

root : Model -> ( Crumbs, List (Html Msg) )
root model =
  let
    crumbs =
      [("About", "#about")]
  in
    ( crumbs, build )


build : List (Html Msg)
build =
  [ div [class "row"]
      [ p [] [text "about!"]
      ]
  ]
