module Layout exposing (root)

import Html exposing (Html, div, a, p, text, footer)
-- import Html.Attributes exposing (class, href)
-- import Html.Events exposing (onClick)
import Types exposing (..)
-- import Routing exposing (Route(..))
-- import Page.Home.View
-- import Page.Live.View
-- import Page.About.View
-- import Page.NotFound.View


root : Model -> Html Msg -> Html Msg
root model msg =
  div []
    [ p [] [text "Header!"]
    , msg
    , p [] [text "Footer!"]
    ]
