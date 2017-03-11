module Photo.WidgetView exposing (root)

-- import Date.Format
import Types exposing (Msg)
import Photo.Types exposing (Model)
import TypeUtil exposing (RemoteData(Loaded))
import Photo.Types exposing (Model, Photos)
import Html exposing (Html, div, text, input, p, span, img, a)
import Html.Attributes exposing (class, src, width, height, href, id)
import ViewUtil exposing (fa, waiting)
-- import Html.Events exposing (on, onInput, keyCode)


root : Photo.Types.Model -> List (Html Msg)
root model =
  [ div [ class "photo-widget" ]
      [ div [ class "photo-feed" ] (photos model)
      , p [ class "photo-more" ]
          [ a [ href "#" ]
              [ text "Load Next Four" ]
          , fa "long-arrow-right"
          ]
      , p [ class "clearer" ] []
      ]
   ]

numPerPage : Int
numPerPage = 4

photos : Model -> List (Html Msg)
photos model =
  case model of
    Loaded photos ->
      actualPhotos photos
    _ ->
      [ waiting ]

actualPhotos : Photos -> List (Html Msg)
actualPhotos photos =
  let
    end   = photos.page * numPerPage
    start = end - 4
    set   = List.drop start photos.list
              |> List.take numPerPage
    build ph =
      let
        thumb = ph.thumb
      in
        a [ href "#" ]
          [ img
              [ src thumb.url
              , width thumb.width
              , height thumb.height
              ]
              []
          ]
  in
    List.map build set

  -- , div [ id "photo-widget", class "photo-widget" ]
  --     [ div [ id "photo-feed" ] []
  --     , p [ class "photo-more" ]
  --         [ a [ id "photo-more-link", href "#" ]
  --             [ text "Load Next Four" ]
  --         , fa "long-arrow-right"
  --         ]
  --     , p [ class "clearer" ] []
  --     ]
