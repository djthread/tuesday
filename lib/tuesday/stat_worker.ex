defmodule Tuesday.Stats do
  defstruct viewers: nil, listeners: nil, online: 0
end

defmodule Tuesday.StatWorker do
  @moduledoc """
  Watches server stats and publishes changes
  """

  use GenServer

  require Logger

  alias Tuesday.Stats

  @rtmp_url        Application.get_env :tuesday, :rtmp_stat_url
  @icecast_url     Application.get_env :tuesday, :icecast_stat_url
  @name            __MODULE__
  @refresh_seconds 4
  @unknown         "unknown"

  def start_link() do
    opts = []
    |> Keyword.put_new(:name, @name)

    GenServer.start_link(@name, [], opts)
  end

  def state do
    GenServer.call(@name, :state)
  end

  def user_joined_lobby do
    GenServer.call(@name, :user_joined_lobby)
  end

  def user_left_lobby do
    GenServer.call(@name, :user_left_lobby)
  end

  def init([]) do
    {:ok, do_refresh(%Stats{})}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:user_joined_lobby, _from, state) do
    state =
      case state.online do
        0 ->
          st = do_refresh(state)
          schedule_refresh()
          st
        _ -> state
      end

    new_state = Map.put(state, :online, state.online + 1)
    Tuesday.Endpoint.broadcast! "rooms:stat", "update", new_state
    {:reply, new_state, new_state}
  end

  def handle_call(:user_left_lobby, _from, state) do
    new_state = Map.put(state, :online, state.online - 1)
    Tuesday.Endpoint.broadcast! "rooms:stat", "update", new_state
    {:reply, new_state, new_state}
  end

  def handle_info(:refresh, state = %Stats{}) do
    state = do_refresh(state)
    if state.online > 0 do
      schedule_refresh()
    end
    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_seconds * 1000)
  end

  defp do_refresh(state = %Stats{}) do
    viewers =
      case HTTPoison.get(@rtmp_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> rtmp_extract_count
        _ ->
          @unknown
      end

    listeners =
      case HTTPoison.get(@icecast_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> icecast_extract_count
        _ ->
          @unknown
      end

    new_state = %Stats{state | viewers: viewers, listeners: listeners}

    maybe_broadcast_state(state, new_state)

    new_state
  end

  defp rtmp_extract_count(body) do
    [_, count | _] = Regex.run(~r|<nclients>(\d+)</nclients>|, body)

    case count == "0" or count == "1" do
      true  -> 0
      false -> count |> Integer.parse |> elem(0) |> :erlang.-(1)
    end
  end

  defp icecast_extract_count(body) do
    case Regex.run(~r|"listeners":(\d+)|, body) do
      [_, count | _] -> count |> Integer.parse |> elem(0)
      _              -> 0
    end
  end

  defp maybe_broadcast_state(old_state, old_state), do: nil
  defp maybe_broadcast_state(_old_state, new_state) do
    # PubSub.publish(new_state.update_topic, new_state)
    # Logger.info "New state: #{new_state |> inspect}"
    Tuesday.Endpoint.broadcast! "rooms:stat", "update", new_state
  end
end
