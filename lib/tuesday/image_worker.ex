defmodule Tuesday.ImageWorker do
  @moduledoc """
  Watches some dirs, corresponding to user accounts, for uploaded images.
  When one appears,

  * Wait for it to finish getting bigger
  * Resize it to two versions with max dimensions:
    * 2000x2000
    * 250x250
  * Add an entry to the db
  * Notify the lobby
  """

  use GenServer
  import Mogrify
  require Logger

  @name             __MODULE__
  @file_pattern     ~r/\.(png|jpg|jpeg|gif)$/i
  @image_dirs       Application.get_env(:tuesday, :image_dirs)
  @image_output_dir Application.get_env(:tuesday, :image_output_dir)

  @refresh_seconds_short 2
  @refresh_seconds_long  4

  def start_link(opts \\ []) do
    GenServer.start_link(@name, [], name: @name)
  end

  def init([]) do
    # state =  # %{thread: %{dir: "/foo"}}
    #   @image_dirs
    #   |> Enum.reduce(%{}, fn({user, dir}, acc) ->
    #       Map.put(acc, user, %{
    #         dir: dir
    #       })
    #      end).()
    #
    {:ok, []}
  end

  def handle_info(:refresh, state) do
    {state, secs} =
      case length(state) do
        0 -> {do_check_dirs(state), @refresh_seconds_long}
        _ -> {do_check_jobs(state), @refresh_seconds_short}
      end

    schedule_refresh(secs)

    {:noreply, state}
  end

  defp do_check_dirs(state) do
    Enum.reduce @image_dirs, [], fn({user, dir}, acc) ->
      File.ls!(dir)
      |> Enum.filter(fn(f) ->
          Regex.match?(@file_pattern, f)
         end).()
      |> do_process_files(user)
      |> Kernel.++(acc)
    end
  end

  defp do_process_files(files, user) do
    Enum.each files, fn(f) ->
      open(f) |> copy |> resize("2000x2000") |> save(
    end
  end

  defp do_check_jobs(state) do
  end

  defp schedule_refresh(secs) do
    Process.send_after(self, :refresh, secs * 1000)
  end

  @doc ~S"""
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
    if state.online == 0 do
      state = do_refresh(state)
      schedule_refresh()
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
  """
end
