module ViewUtil exposing (..)

import Html exposing (Html, Attribute, div, span, text, button, i, a, sup, ul, li)
import Html.Attributes exposing (style, class, attribute, href, target, disabled, tabindex)
import Html.Events exposing (onWithOptions, defaultOptions)
import Json.Decode
import Types exposing (..)
import Data.Types
import TypeUtil exposing (Pager)
import Date exposing (Date)
import Date.Format


formatDate : Date -> String
formatDate date =
  Date.Format.format "%A, %B %d" date


waiting : Html Msg
waiting =
  div [ class "loading" ]
    [ i [ class "fa fa-spinner fa-spin fa-2x fa-fw"
        , attribute "aria-hidden" "true"
        ]
        [ span [ class "sr-only" ] [ text "Loading..." ]
        ]
    ]


myOnClick : Msg -> Attribute Msg
myOnClick msg =
  let options =
    { defaultOptions
    | preventDefault = True
    }
  in
    onWithOptions "click" options (Json.Decode.succeed msg)


toggle : Bool -> Attribute msg
toggle bool =
  let display =
    case bool of
      True  -> "block"
      False -> "none"
  in
    style [("display", display)]


fa : String -> Html Msg
fa icon =
  i [ class ("fa fa-" ++ icon)
    , attribute "aria-hidden" "true"
    ] []


socialButtons : Html Msg
socialButtons =
  div [ class "social-buttons" ]
    [ a [ class "btn"
        , href "https://twitter.com/impulsedetroit"
        , target "_blank"
        ]
        [ fa "twitter"
        , span [ style [("display", "none")] ] [ text "T" ]
        , text "witter"
        -- , sup [ class "ext" ] [ fa "external-link" ]
        ]
    , a [ class "btn"
        , href "https://facebook.com/impulsedetroit"
        , target "_blank"
        ]
        [ fa "facebook"
        , span [ style [("display", "none")] ] [ text "F" ]
        , text "acebook"
        -- , sup [ class "ext" ] [ fa "external-link" ]
        ]
    , a [ class "btn"
        , href "https://www.instagram.com/impulsedetroit"
        , target "_blank"
        ]
        [ fa "instagram"
        , span [ style [("display", "none")] ] [ text "I" ]
        , text "nstagram"
        -- , sup [ class "ext" ] [ fa "external-link" ]
        ]
    ]



paginator : Pager -> List (Html Msg)
paginator pager =
  let
    ( page, total ) =
      ( pager.pageNumber, pager.totalEntries )
    -- g = Debug.log "PAGE" page
    el =
      span [] [ text "..." ]
    buildLi active msg =
      li
        [ class ("page-item" ++ if active then " active" else "") ]
        [ msg ]
    buildNum active num =
      buildLi active
        ( a [ myOnClick (fetchPg num) ]
            [ text (toString num) ]
        )
    previous =
      let
        dis =
          if page == 1 then
            [ attribute "disabled" "disabled" ]
          else
            []
      in
        [ buildLi False
            (a ([ href "#" , tabindex -1 ] ++ dis) [ text "Previous" ])
        ]
    fetchPg =
      \p -> DataMsg (Data.Types.FetchEpisodePage p)
    el1 =
      if page > 3 then [el] else []
    before =
      if page == 1 then [] else
        let
          tmp = page - 2
          start = if tmp < 1 then 1 else tmp
        in
          List.map (buildNum False) (List.range start page)
    active =
      [ buildNum True page ]
    after =
      if page == total then [] else
        let
          tmp = page + 2
          finish = if tmp > total then total else tmp
        in
          List.map (buildNum False) (List.range (page + 1) finish)
    el2 =
      if page < (total - 2) then [el] else []
    next =
      let
        dis =
          if page == total then
            [ attribute "disabled" "disabled" ]
          else
            []
      in
        [ buildLi False
            (a ([ href "#" , tabindex -1 ] ++ dis) [ text "Next" ])
        ]
  in
    [ ul [ class "pagination" ]
        ( previous
          ++ firstPage
          ++ el1
          ++ before
          ++ active
          ++ after
          ++ el2
          ++ lastPage
          ++ next
        )
    ]
    --
    --     , li [ class "page-item active" ]
    --         [ a [ myOnClick (fetchPg 1) ]
    --             [ text "1" ]
    --         ]
    --     , li [ class "page-item" ]
    --         [ a [ href "#" ] [ text "2" ] ]
    --     , li [ class "page-item" ]
    --         [ a [ href "#" ] [ text "3" ] ]
    --     , li [ class "page-item" ]
    --         [ span [] [ text "..." ] ]
    --     , li [ class "page-item" ]
    --         [ a [ href "#" ] [ text "12" ] ]
    --     , li [ class "page-item" ]
    --         [ a [ href "#" ] [ text "Next" ] ]
    --     ]
    -- ]
