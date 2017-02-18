module Layout exposing (root)

import Html exposing (Html, Attribute,
  div, a, p, text, footer, span, ul, li, h1, header, section, i, button)
import Html.Attributes exposing (class, href, attribute, title, style)
-- import Html.Events exposing (onClick)
import Types exposing (..)
-- import Routing exposing (Route(..))
-- import Page.Home.View
-- import Page.About.View
-- import Page.NotFound.View


root : Model -> Html Msg -> Html Msg
root model msg =
  div []
    [ myheader model
    , div []
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
    loading = False
  in
    header [class "navbar"]
      [ section [class "navbar-section"]
          [ div [class "loading", toggle loading] []
          , a [href "#", class "navbar-brand"]
              [ i [class "icon icon-pages", title "Impulse Detroit"] []
              , text "impulse Detroit"
              ]
          , a [href "#shows", class "btn btn-link"] [text "Shows"]
          , a [href "#schedule", class "btn btn-link"] [text "Schedule"]
          , a [href "#podcast", class "btn btn-link"] [text "Podcast"]
          , a [href "#info", class "btn btn-link"] [text "Info"]
          , a [href "//photos.impulsedetroit.net", class "btn btn-link"] [text "Photos"]
          ]
      ]

toggle : Bool -> Attribute msg
toggle bool =
  let display =
    case bool of
      True  -> "block"
      False -> "none"
  in
    style [("display", display)]
