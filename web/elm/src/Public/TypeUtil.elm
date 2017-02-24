module TypeUtil exposing (..)


type RemoteData a
  = NotAsked
  | Loading
  | Loaded a
