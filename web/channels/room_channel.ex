defmodule Tuesday.RoomChannel do
  use Phoenix.Channel
  use Timex
  require Logger
  alias Tuesday.ChatLog, as: Log

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("rooms:lobby", message, socket) do
    Process.flag(:trap_exit, true)
    # :timer.send_interval(5000, :ping)
    send(self, {:after_join, message})

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

  def terminate(reason, _socket) do
    Logger.debug "> leave #{inspect reason}"

    :ok
  end

  def handle_in("new:msg", msg, socket) do
    {:ok, stamp} = Date.now("America/Detroit") |> DateFormat.format("{ISOz}")

    [event, data] = ["new:msg", %{
      user:  msg["user"],
      body:  msg["body"],
      stamp: stamp
    }]

    broadcast! socket, event, data
    Log.append event: event, data: data

    # socket = socket |> assign(:user, msg["user"])
    {:reply, {:ok, %{msg: msg["body"]}}, socket}
  end
end
