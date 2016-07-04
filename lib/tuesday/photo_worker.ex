defmodule Tuesday.Photo do
  defstruct url: nil, width: nil, height: nil, full_url: nil
end

defmodule Tuesday.PhotoWorker do
  @moduledoc """
  Holds info about the last few photos in the Piwigo gallery
  and keep clients in sync.
  """

  use GenServer

  require Logger

  alias Tuesday.Photo

  @feed_url Application.get_env :tuesday, :piwigo_feed_url
  @name     __MODULE__

  def start_link() do
    opts = []
    |> Keyword.put_new(:name, @name)

    GenServer.start_link(@name, [], opts)
  end

  def photos do
    GenServer.call(@name, :photos)
  end

  def refresh do
    GenServer.call(@name, :refresh)
  end

  def init([]) do
    {:ok, MapSet.new |> do_refresh}
  end

  def handle_call(:photos, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:refresh, _from, state) do
    state = state |> do_refresh
    {:reply, state, state}
  end

  # def handle_call(:user_joined_lobby, _from, state) do
  #   if state.online == 0 do
  #     state = do_refresh(state)
  #     schedule_refresh()
  #   end
  #   new_state = Map.put(state, :online, state.online + 1)
  #   Tuesday.Endpoint.broadcast! "rooms:stat", "update", new_state
  #   {:reply, new_state, new_state}
  # end
  #
  # def handle_call(:user_left_lobby, _from, state) do
  #   new_state = Map.put(state, :online, state.online - 1)
  #   Tuesday.Endpoint.broadcast! "rooms:stat", "update", new_state
  #   {:reply, new_state, new_state}
  # end
  #
  # def handle_info(:refresh, state = %Stats{}) do
  #   state = do_refresh(state)
  #   if state.online > 0 do
  #     schedule_refresh()
  #   end
  #   {:noreply, state}
  # end
  #
  # defp schedule_refresh do
  #   Process.send_after(self(), :refresh, @refresh_seconds * 1000)
  # end
  #
  def do_refresh(old_mapset) do
    new_mapset =
      case HTTPoison.get(@feed_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> parse_photos
        _ ->
          nil
      end

    broadcast_new_photos(old_mapset, new_mapset)

    new_mapset
  end

  defp parse_photos(body) do
    # Floki isn't letting me find("_2small") for some reason,
    # so i'll just rewrite those nodes
    body
    |> String.replace("_2small>", "thisone>")
    |> Floki.find("thisone")
    |> Enum.map(&parse_item/1)
    |> Enum.filter(fn(x) -> x != nil end)
    |> Enum.map(&fix_item/1)
    |> MapSet.new
  end

  defp parse_item({_size, [], [{"url", [], [url]}, {"width", [], [width]}, {"height", [], [height]}]}) do
    %Photo{url: url, width: width, height: height}
  end
  defp parse_item(x) do
    Logger.warn "Ignored photo from feed: " + inspect(x)
    nil
  end

  defp fix_item(photo = %Photo{}) do
    full_url = String.replace photo.url, "-2s.jpg", "-xl.jpg"
    %Photo{photo | full_url: full_url}
  end

  defp broadcast_new_photos(old_mapset, new_mapset) when old_mapset == new_mapset, do: nil
  defp broadcast_new_photos(old_mapset, new_mapset) do
    new_mapset
    |> MapSet.difference(old_mapset)
    |> Enum.each(&broadcast/1)
  end

  defp broadcast(photo = %Photo{}) do
    Tuesday.Endpoint.broadcast! "photos", "new", photo
  end

end
