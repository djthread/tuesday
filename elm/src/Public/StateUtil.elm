module StateUtil exposing (..)

import Types exposing (..)
import TypeUtil exposing (RemoteData(..))
import Chat.Types
import Data.Types exposing (doShowThingOr)
import Json.Encode as JE
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Socket as Socket
import Phoenix.Push as Push
import Routing exposing (Route, Route(..))
import Port


routeCmd : Route -> RemoteData Data.Types.Shows
        -> RemoteData Data.Types.EventListing
        -> RemoteData Data.Types.EpisodeListing
        -> ( NavSection, Cmd Msg )
routeCmd route rdShows rdEvents rdEpisodes =
  let
    showBit =
      doShowThingOr rdShows ""
        (\show -> show.name ++ " : ")
    ( section, pageBit ) =
      case route of
        HomeRoute ->
          ( None, "" )
        ShowsRoute ->
          ( Shows, "Shows : " )
        ShowRoute slug ->
          ( Shows, showBit slug )
        EpisodesRoute page ->
          ( Episodes
          , "Episodes p." ++ (toString page) ++ " : "
          )
        EventsRoute page ->
          ( Events
          , "Events p." ++ (toString page) ++ " : "
          )
        ShowEpisodesRoute slug page ->
          ( Shows
          , "Episodes p." ++ (toString page)
            ++ " : " ++ showBit slug )
        ShowEventsRoute slug page ->
          ( Events
          , "Events p." ++ (toString page)
            ++ " : " ++ showBit slug )
        -- ShowInfoRoute slug ->
        --   ( Shows
        EventRoute slug evSlug ->
          let
            evBit =
              case rdEvents of
                Loaded listing ->
                  case List.head listing.entries of
                    Just ev -> ev.title ++ " : "
                    Nothing -> ""
                _ -> ""
        in
          ( Events, evBit ++ showBit slug )
        EpisodeRoute slug epSlug ->
          let
            epBit =
              case rdEpisodes of
                Loaded listing ->
                  case List.head listing.entries of
                    Just ep -> ep.title ++ " : "
                    Nothing -> ""
                _ -> ""
        in
          ( Episodes, epBit ++ showBit slug )
        AboutRoute ->
          ( About, "About : " )
        NotFoundRoute ->
          ( None, "404 : " )
        _ ->
          ( None, "" )
  in
    ( section
    , Port.setTitle (pageBit ++ "Impulse Detroit")
    )



startLoading : Model -> Model
startLoading model =
  let
    newCount = model.loading + 1
  in
    { model | loading = newCount }

doneLoading : Model -> Model
doneLoading model =
  let
    newCount = model.loading - 1
  in
    { model | loading = newCount }

-- initSocket : ( (Phoenix.Socket.Socket Types.Msg), Cmd Types.Msg )
-- initSocket =
--   let
--     initSocket =
--       wsUrl
--         |> Phoenix.Socket.init
--         -- |> Phoenix.Socket.withDebug
--         |> Phoenix.Socket.on "new:msg" "rooms:lobby"
--             (\m -> ChatMsg (Chat.Types.ReceiveNewMsg m))
--         |> Phoenix.Socket.on "shows" "data"
--             (\m -> DataMsg (Data.Types.ReceiveShows m))
--     channel =
--       Phoenix.Channel.init "rooms:lobby"
--     ( phxSocket, phxCmd ) =
--       Phoenix.Socket.join channel initSocket
--     onJoin =
--       always SocketInitialized
--     channel2 =
--       Phoenix.Channel.init "data"
--         |> Phoenix.Channel.onJoin onJoin
--     ( phxSocket2, phxCmd2 ) =
--       Phoenix.Socket.join channel2 phxSocket
--     channel3 =
--       Phoenix.Channel.init "instagram"
--     ( phxSocket3, phxCmd3 ) =
--       Phoenix.Socket.join channel3 phxSocket2
--     cmd =
--       Cmd.batch
--         [ Cmd.map PhoenixMsg phxCmd
--         , Cmd.map PhoenixMsg phxCmd2
--         , Cmd.map PhoenixMsg phxCmd3
--         ]
--   in
--     ( phxSocket3, cmd )


pushMsg : String -> String
           -> (JE.Value -> Msg)
           -> Cmd Types.Msg
pushMsg message channel msg =
  pushMsgWithConfigurator
    message channel msg (\a -> a)


pushMsgWithConfigurator : String -> String
  -> (JE.Value -> Types.Msg)
  -> ( Push.Push Types.Msg
      -> Push.Push Types.Msg )
  -> Cmd Types.Msg
pushMsgWithConfigurator
  message channel retMsg configurator =
  let
    configurator2 =
      (\p -> p |> Push.onOk retMsg |> configurator)
  in
    pushMessage message channel configurator2


pushMessage : String -> String
           -> (Push.Push Msg -> Push.Push Msg)
           -> Cmd Types.Msg
pushMessage message channel configurator =
  Push.init channel message
    |> configurator
    |> Phoenix.push wsUrl
