defmodule Tuesday.InstagramWorker do
  @moduledoc """
  Maintains some instagram data
  """

  use GenServer
  require Logger

  @config    Application.get_env :tuesday, :instagram
  @media_url Keyword.get(@config, :media)
  @name      __MODULE__

  def last_four,  do: GenServer.call(@name, :last_four)
  def all_photos, do: GenServer.call(@name, :all_photos)
  def refresh,    do: GenServer.call(@name, :refresh)

  def start_link() do
    opts = [name: @name]

    GenServer.start_link(@name, [], opts)
  end

  def init([]) do
    {:ok, do_refresh []}
  end

  def handle_call(:last_four, _from, state) do
    ret = %{
      last_four: Enum.take(state, 4),
      total:     length(state)
    }

    {:reply, ret, state}
  end

  def handle_call(:all_photos, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:refresh, _from, state) do
    state = state |> do_refresh
    {:reply, state, state}
  end

  def do_refresh(old_mapset) do
    File.read!("test/fixtures/instagram-media.json")
    |> parse
    # case HTTPoison.get(@media_url) do
    #   {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
    #     new_mapset = body |> parse
    #     broadcast_photos(new_mapset)
    #     new_mapset
    #   res ->
    #     Logger.error "Instagram media call failed: #{inspect res}"
    #     old_mapset
    # end
  end

  defp parse(body) do
    Poison.decode!(body)
    |> Map.get("items")
    |> Enum.map(fn item ->

      imgs = item["images"]
      created =
        item["created_time"]
        |> String.to_integer
        |> DateTime.from_unix!
        |> DateTime.to_iso8601

      %{caption: item["caption"]["text"],
        created: created,
        link:    item["link"],
        thumb: %{
          url:    imgs["thumbnail"]["url"],
          width:  imgs["thumbnail"]["width"],
          height: imgs["thumbnail"]["height"]
        },
        low: %{
          url:    imgs["low_resolution"]["url"],
          width:  imgs["low_resolution"]["width"],
          height: imgs["low_resolution"]["height"]
        },
        standard: %{
          url:    imgs["standard_resolution"]["url"],
          width:  imgs["standard_resolution"]["width"],
          height: imgs["standard_resolution"]["height"]
        }
      }
    end)
    |> Enum.sort(fn a, b -> a.created > b.created end)
  end

end
