defmodule Tuesday.ChatLog do
  @buffer 200

  @moduledoc """
  Holds the last @buffer lines of chat
  """

  @doc """
  Start a new chat log
  """
  def start_link do
    Agent.start_link(fn -> [] end)
  end

  @doc """
  Get `num` of the last lines in the log
  """
  def lines(agent, num) when is_pid(agent) and is_integer(num) do
    Agent.get(agent, fn(list) ->
      list
      |> Enum.take(num)
      |> Enum.reverse
    end)
  end

  @doc """
  Add a `line` to the log
  """
  def append(agent, line) when is_pid(agent) and is_binary(line) do
    Agent.update(agent, fn(log) -> [line | log] end)
  end
end
