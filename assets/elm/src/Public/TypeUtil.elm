module TypeUtil exposing (..)


type RemoteData a
  = NotAsked
  | Loading
  | Loaded a


type alias Pager =
  { pageNumber   : Int
  , pageSize     : Int
  , totalPages   : Int
  , totalEntries : Int
  }
