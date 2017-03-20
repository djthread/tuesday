module Page.About.View exposing (root)

import Html exposing (Html, div, p, a, text, footer, img)
import Html.Attributes exposing (class, href, alt, src )
import Html.Events exposing (onClick)
import Types exposing (..)
import Markdown

root : Model -> ( Crumbs, List (Html Msg) )
root model =
  let
    crumbs =
      [("About", "")]
  in
    ( crumbs, build )


build : List (Html Msg)
build =
  [ buildImg
  , Markdown.toHtml [] buildMarkdown
  ]

buildImg : Html Msg
buildImg =
  let
    alt_ = "Sinister Dosage throwing down"
    src_ =
      "https://photos.impulsedetroit.net/i/upload/" ++
        "2017/03/20/20170320144555-ebb5e1fa-me.jpg"
  in
    img [ class "righty", src src_, alt alt_ ] []

buildMarkdown : String
buildMarkdown =
  """
  ## What is Impulse Detroit?

  We are a group of DJs and music-lovers who want to share the art of production and DJing for others, whether they are present at the live event, tune in to the live stream, or subscribe to the podcast and listen at will.


  ## Why?

  Hi! I'm Adam Bellinson, and I am a drum & bass addict. Having mixed the genre, exclusively, since 2005, I decided to continue a weekly show some friends were throwing, but had lost the venue for. I've been hosting [Techno Tuesday](#/shows/techno-tuesday) at the Urban Bean since January 2015.

  In January 2016, I had a Rocket Fiber internet connection installed to my home. In thinking of new applications for my symmetric 1 Gb/s connection, I soon launched a website to host Techno Tuesday. A couple months later, we've launched Impulse Detroit -- a group of internet shows, dedicated to bringing quality choonage to your ear-holes.


  ## Questions? Comments?

  Let us know!

  * Email: [impulsedetroit@gmail.com](mailto:impulsedetroit@gmail.com)
  * Twitter: [@impulsedetroit](https://www.twitter.com/impulsedetroit)
  * Facebook: [impulsedetroit](https://www.facebook.com/impulsedetroit)


  ## The Nerdy

  Because it bears mentioning, a huge impetus for this project has been my own passion to learn the best ways to build websites and other software. [Elixir](http://elixir-lang.org/) is the backend technology that has changed the way I think about software, and [Elm](http://elm-lang.org/) has more recently proven to have a similar affect!
  """
