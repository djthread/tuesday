defmodule Tuesday.InstagramWorker do
  @moduledoc """
  Maintains some instagram data
  """

  use GenServer
  require Logger

  @config    Application.get_env :tuesday, :instagram
  @media_url Keyword.get(@config, :media_url)
  @name      __MODULE__

  def photos,  do: GenServer.call(@name, :photos)
  def refresh, do: GenServer.call(@name, :refresh)

  def start_link do
    opts = [name: @name]

    GenServer.start_link(@name, [], opts)
  end

  def init([]) do
    {:ok, do_refresh []}
  end

  def handle_call(:photos, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:refresh, _from, state) do
    state = state |> do_refresh
    {:reply, state, state}
  end

  def do_refresh(old_mapset) do
    if ! @media_url do
      Logger.info "InstagramWorker: Loading from fixture"
      File.read!("test/fixtures/instagram-media.json")
      |> parse
    else
      case HTTPoison.get(@media_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          new_mapset = body |> parse
          # broadcast_photos(new_mapset)
          new_mapset
        res ->
          Logger.error "Instagram media call failed: #{inspect res}"
          old_mapset
      end
    end
  end

  defp parse(body) do
    mapper = fn item ->
      imgs = item["images"]
      created =
        item["created_time"]
        |> String.to_integer
        |> DateTime.from_unix!
        |> DateTime.to_iso8601

      full_url =
        imgs["standard_resolution"]["url"]
        |> fn s ->
        ~r{/s640x640/[a-z][a-z]\d\.\d\d/}
        |> Regex.replace(s, "/")
      end.()
      |> fn s ->
          ~r{/((?:s|e)\d\d)/c[\d\.]+/}
          |> Regex.replace(s, "/\\g{1}/")
        end.()

      %{caption:  item["caption"]["text"],
        created:  created,
        link:     item["link"],
        full_url: full_url,
        thumb: %{
          url:    imgs["thumbnail"]["url"],
          width:  imgs["thumbnail"]["width"],
          height: imgs["thumbnail"]["height"]
        }
      }
    end

    Poison.decode!(body)
    |> Map.get("items")
    |> Enum.map(mapper)
    |> Enum.sort(fn a, b -> a.created > b.created end)
  end

end
