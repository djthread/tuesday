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

  def photos,  do: GenServer.call(@name, :photos)
  def refresh, do: GenServer.call(@name, :refresh)

  def start_link() do
    opts = []
    |> Keyword.put_new(:name, @name)

    GenServer.start_link(@name, [], opts)
  end

  def init([]) do
    Tuesday.PhotoWatcher.start
    {:ok, MapSet.new |> do_refresh}
  end

  def handle_call(:photos, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:refresh, _from, state) do
    state = state |> do_refresh
    {:reply, state, state}
  end

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
    # I can't Floki.find("_2small") for some reason,
    # so i'll just rewrite those nodes
    body = String.replace(body, "_2small", "mythumbnail");

    urls =
      body
      |> Floki.find("image")
      |> Enum.map(fn({"image", attrs, _photos}) ->
        attrs
        |> Enum.find(nil, fn({f, _}) -> f == "page_url" end)
        |> elem(1)
      end)

    body
    |> Floki.find("mythumbnail")
    |> parse_items(urls)
    |> Enum.filter(fn(x) -> x != nil end)
    |> Enum.map(&fix_item/1)
    |> MapSet.new
  end

  defp parse_items(items, urls, ret \\ [])
  defp parse_items([i | items], [u | urls], ret) do
    parse_items items, urls, [%Photo{parse_item(i) | gallery_url: u} | ret]
  end
  defp parse_items([], _, ret), do: ret

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
