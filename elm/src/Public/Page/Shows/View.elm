module Page.Shows.View exposing (root)

import Html exposing (Html, h2, h3, h4, div, text, p, a, figure, img)
import Html.Attributes exposing (class, href, src)
import Types exposing (..)
import Data.Types exposing (Show, findShowBySlug)
import TypeUtil exposing (RemoteData(Loaded))
import ViewUtil exposing (waiting)
import Markdown


root : Model -> ( Crumbs, List (Html Msg) )
root model =
  let
    msgs =
      case model.data.shows of
        Loaded shows -> buildShowList shows
        _            -> [ waiting ]
    crumbs =
      [ ( "Shows", "" ) ]
  in
    ( crumbs, msgs )


buildShowList : List Show -> List (Html Msg)
buildShowList shows =
  let
    getShow = findShowBySlug shows
  in
    [ day "Monday"  [ getShow "sub-therapy-radio" |> buildShow ]
    , day "Tuesday" [ getShow "techno-tuesday"    |> buildShow ]
    , day "Friday"  [ getShow "wobblehead-radio"  |> buildShow ]
    , day "Also,"   [ getShow "specials"          |> buildShow ]
    ]


-- showImage : String -> String
-- showImage slug =
--   case slug of
--     "techno-tuesday" ->
--       "https://impulsedetroit.net/images/showbtns/techno-tuesday.jpg"
--     "wobblehead-radio" ->
--       "https://impulsedetroit.net/images/showbtns/techno-tuesday.jpg"
--     _ ->
--       "https://impulsedetroit.net/images/showbtns/techno-tuesday.jpg"


buildShow : Maybe Show -> Html Msg
buildShow maybeShow =
  case maybeShow of
    Nothing -> p [] []
    Just show ->
      a [ class "sh-show", href ("#shows/" ++ show.slug) ]
        [
          -- figure [ class "avatar avatar-xl" ]
          --   [ img [ src (showImage show.slug) ] [] ]
          h4 [] [ text show.name ]
        , Markdown.toHtml [] show.tinyInfo
        , p [ class "clearer" ] [ text "" ]
        ]


day : String -> List (Html Msg) -> Html Msg
day name htmls =
  let
    thetitle =
      [ h3 [] [ text name ] ]
  in
    div [ class "sh-day" ]
      (thetitle ++ htmls)

