module Layout exposing (root)

import Html exposing (Html,
  div, a, p, text, footer, span, ul, li, h1, header, section, i, button)
import Html.Attributes exposing (class, href, attribute, title, style)
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
    [ myheader model
    , div [class "container"]
        [ msg
        , div [class "modal-footer"]
            [ button [class "btn btn-link"] [text "Close"]
            , button [class "btn btn-primary"] [text "Share"]
            ]
        ]
    ]

myheader : Model -> Html Msg
myheader model =
  let
    loading = "none"
  in
    header [class "navbar"]
      [ section [class "navbar-section"]
          [ div [class "loading", style [("display", loading)]] []
          , a [href "#", class "navbar-brand"]
              [ i [class "icon icon-pages", title "Impulse Detroit"] []
              , text "impulse Detroit"
              ]
          , a [href "#live", class "btn btn-link"] [text "Live"]
          , a [href "#shows", class "btn btn-link"] [text "Shows"]
          ]
      ]
