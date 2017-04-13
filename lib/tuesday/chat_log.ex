defmodule Tuesday.ChatLog do
  @moduledoc """
  Holds the last `@buffer` lines of chat
  """

  import Ecto.Query
  alias Tuesday.{Repo, ChatEntry}

  @name __MODULE__
  @buffer 100

  @doc "Start a new chat log"
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)

    Agent.start_link(fn -> load_log end, opts)
  end

  @doc "Get `num` of the last lines in the log"
  def lines(num) when is_integer(num) do
    lines(@name, num)
  end
  def lines(agent, num) when is_integer(num) do
    Agent.get agent, fn(list) ->
      list
      |> Enum.take(num)
      |> Enum.reverse
    end
  end

  @doc "Add a `line` to the internal log & db"
  def append(entry = %ChatEntry{}) do
    append(@name, entry)
  end
  def append(agent, entry = %ChatEntry{}) do
    newEntry =
      entry
      |> Repo.insert!

    Agent.update agent, fn(log) ->
      [newEntry | log]
    end

    newEntry
  end

  defp load_log do
    Repo.all from ChatEntry,
      order_by: [desc: :inserted_at],
      limit: 20
  end

end
