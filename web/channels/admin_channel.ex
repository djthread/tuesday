defmodule Tuesday.RoomChannel do
  use Phoenix.Channel
  use Calendar

  require Logger

  alias Tuesday.ChatLog, as: Log
  alias Tuesday.StatWorker

  @lobbyroom "rooms:lobby"
  @statroom  "rooms:stat"

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join(@lobbyroom, message, socket) do
    Process.flag(:trap_exit, true)

    StatWorker.user_joined_lobby()

    # :timer.send_interval(5000, :ping)

    send(self, {:after_join, message})

    {:ok, socket}
  end

  def join(@statroom, message, socket) do
    Process.flag(:trap_exit, true)
    send(self, :after_stat_join)

    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, _msg}, socket) do
    push socket, "join", %{status: "connected"}
    40 |> Log.lines |> Enum.each(&push socket, &1[:event], &1[:data])

    {:noreply, socket}
  end

  def handle_info(:after_stat_join, socket) do
    push socket, "update", StatWorker.state()
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    if socket.topic == @lobbyroom do
      StatWorker.user_left_lobby()
    end

    Logger.debug "> leave #{inspect reason} (#{socket.topic})"

    :ok
  end

  def handle_in("new:msg", msg, socket) do
    [event, data] = ["new:msg", %{
      user:  msg["user"],
      body:  msg["body"],
      stamp: DateTime.now_utc |> DateTime.Format.rfc3339
    }]

    broadcast! socket, event, data
    Log.append event: event, data: data

    # socket = socket |> assign(:user, msg["user"])
    {:reply, {:ok, %{msg: msg["body"]}}, socket}
  end
end
