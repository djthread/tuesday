module ViewUtil exposing (..)

import Html exposing (Html, Attribute, div, span, text, button, i, a)
import Html.Attributes exposing (style, class, attribute, href, target)
import Html.Events exposing (onWithOptions, defaultOptions)
import Json.Decode
import Types exposing (..)
import Date exposing (Date)
import Date.Format


formatDate : Date -> String
formatDate date =
  Date.Format.format "%A, %B %d" date


waiting : Html Msg
waiting =
  div [ class "loading" ] []


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


socialButtons : Html Msg
socialButtons =
  div [ class "social-buttons" ]
    [ a [ class "btn"
        , href "https://twitter.com/impulsedetroit"
        , target "_blank"
        ]
        [ i [ class "fa fa-twitter"
            , attribute "aria-hidden" "true"
            ] []
        , span [ style [("display", "none")] ] [ text "T" ]
        , text "witter"
        ]
    , a [ class "btn"
        , href "https://facebook.com/impulsedetroit"
        , target "_blank"
        ]
        [ i [ class "fa fa-facebook"
            , attribute "aria-hidden" "true"
            ] []
        , span [ style [("display", "none")] ] [ text "F" ]
        , text "acebook"
        ]
    , a [ class "btn"
        , href "https://www.instagram.com/impulsedetroit"
        , target "_blank"
        ]
        [ i [ class "fa fa-instagram"
            , attribute "aria-hidden" "true"
            ] []
        , span [ style [("display", "none")] ] [ text "I" ]
        , text "nstagram"
        ]
    ]
    -- <div class="buttons bit sm">
    --   <ul>
    --     <li>
    --       <a href="https://twitter.com/impulsedetroit">
    --         <i class="fa fa-twitter"></i>witter
    --       </a>
    --     </li>
    --     <li>
    --       <a href="https://facebook.com/impulsedetroit">
    --         <i class="fa fa-facebook"></i>acebook
    --       </a>
    --     </li>
    --     <li>
    --       <a href="https://www.instagram.com/impulsedetroit">
    --         <i class="fa fa-instagram"></i>nstagram
    --       </a>
    --     </li>
    --     <li>
    --       <a href="mailto:impulsedetroit@gmail.com">
    --         <i class="fa fa-envelope"></i>mail
    --       </a>
    --     </li>
    --   </ul>
    --   </ul>
    -- </div>
