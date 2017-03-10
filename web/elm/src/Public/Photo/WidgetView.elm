module Photo.WidgetView exposing (root)

-- import Date.Format
import Types exposing (Msg)
import Photo.Types exposing (Model)
-- import Chat.Types exposing (Msg(..), Line)
import Html exposing (Html, div, text, input, p, span)
import Html.Attributes exposing (class)
-- -- import Html.Events exposing (onInput, onClick)
-- import Html.Events exposing (on, onInput, keyCode)
-- import Json.Decode as JD


root : Photo.Types.Model -> List (Html Msg)
root model =
  [ div [ class "photo-widget" ]
      [ div [ class "photo-feed" ] []
      ]
  ]
  -- , div [ id "photo-widget", class "photo-widget" ]
  --     [ div [ id "photo-feed" ] []
  --     , p [ class "photo-more" ]
  --         [ a [ id "photo-more-link", href "#" ]
  --             [ text "Load Next Four" ]
  --         , fa "long-arrow-right"
  --         ]
  --     , p [ class "clearer" ] []
  --     ]
