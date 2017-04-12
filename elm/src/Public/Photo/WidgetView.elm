module Photo.WidgetView exposing (root)

-- import Date.Format
import Types exposing (Msg)
import Photo.Types exposing (Model)
import TypeUtil exposing (RemoteData(Loaded))
import Photo.Types exposing (Model, Photos)
import Html exposing (Html, div, text, input, p, span, img, a)
import Html.Attributes exposing (attribute, class, style, src, width, height, href, id, alt, target)
import ViewUtil exposing (fa, waiting, myOnClick)


root : Photo.Types.Model -> List (Html Msg)
root model =
  [ div [ class "photo-widget" ]
      [ div [ id "photo-feed", class "photo-feed" ] (photos model)
      , p [ class "photo-more" ]
          [ a [ class "btn btn-sm"
              , href "https://www.instagram.com/impulsedetroit"
              , target "_blank"
              ]
              [ text "Impulse Detroit on Instagram "
              , fa "instagram"
              ]
          , text " "
          , a [ class "btn btn-sm"
              , href "#"
              , myOnClick (Types.PhotoMsg Photo.Types.ShowNextFour)
              ]
              [ text "Load Next Four "
              , fa "long-arrow-right"
              ]
          ]
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
      let thumb = ph.thumb
      in
        a [ href ph.link, target "_blank" ]
          [ img
              [ class "jslghtbx-thmb"
              , src thumb.url
              , alt ph.caption
              , attribute "data-jslghtbx" ph.full_url
              -- , attribute "data-jslghtbx-group" "one"
              , attribute "data-jslghtbx-caption"
                  ( ph.caption
                    ++ " <span>[<a href=\"" ++ ph.link
                    ++ "\" target=\"_blank\">"
                    ++ "Instagram</a>]</span>"
                  )
              , width thumb.width
              , height thumb.height
              ]
              []
          ]
  in
    List.map build set
