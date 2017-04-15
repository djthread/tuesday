defmodule Tuesday.Web.RoomChannel do
  use Tuesday.Web, :channel

  alias Tuesday.ChatLog
  alias Tuesday.ChatEntry
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

    # StatWorker.user_joined_lobby()

    # :timer.send_interval(5000, :ping)

    send(self(), {:after_join, message})

    {:ok, socket}
  end

  def join(@statroom, _message, socket) do
    Process.flag(:trap_exit, true)
    send(self(), :after_stat_join)

    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, _msg}, socket) do
    push socket, "join", %{status: "connected"}

    msgAccessor = fn entry ->
      entry.msg
    end

    20
    |> ChatLog.lines()
    |> Enum.each(&push socket, msgAccessor.(&1), entryToMap(&1))

    {:noreply, socket}
  end

  # def handle_info(:after_stat_join, socket) do
  #   push socket, "update", StatWorker.state
  #
  #   {:noreply, socket}
  # end

  def terminate(reason, socket) do
    if socket.topic == @lobbyroom do
      # StatWorker.user_left_lobby()
    end

    Logger.debug "> leave #{inspect reason} (#{socket.topic})"

    :ok
  end

  def handle_in("new:msg", %{"body" => body, "nick" => nick}, socket) do
    nick_ = String.trim(nick)
    body_ = String.trim(body)

    if String.length(body_) > 0 and String.length(nick_) > 0 do
      process socket,
        %ChatEntry{
          msg: "new:msg",
          nick: nick_,
          body: body_
        }
    end

    {:reply, :ok, socket}
  end

  defp process(socket, entry = %ChatEntry{}) do
    newEntry = entry |> ChatLog.append

    broadcast!(socket, newEntry.msg, entryToMap(newEntry))
  end

  defp entryToMap(entry = %ChatEntry{}) do
    %{nick: entry.nick,
      body: entry.body,
      stamp: entry.inserted_at |> DateTime.Format.rfc3339
    }
  end
end
