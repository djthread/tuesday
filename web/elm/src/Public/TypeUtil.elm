module TypeUtil exposing (..)


type RemoteData a
  = NotAsked
  | Loading
  | Ok a