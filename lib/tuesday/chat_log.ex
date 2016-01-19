defmodule Tuesday.ChatLog do
  @name __MODULE__
  @buffer 100

  @moduledoc """
  Holds the last @buffer lines of chat
  """

  # @doc """
  # Start a new chat log
  # """
  # def start_link_multi(opts \\ []) do
  #   Agent.start_link fn -> [] end, opts
  # end

  @doc """
  Start a new chat log
  """
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link fn -> [] end, opts
  end

  @doc """
  Get `num` of the last lines in the log
  """
  def lines(num) when is_integer(num) do lines(@name, num) end
  def lines(agent, num) when is_integer(num) do
    Agent.get agent, fn(list) ->
      list
      |> Enum.take(num)
      |> Enum.reverse
    end
  end

  @doc """
  Add a `line` to the log
  """
  def append(line) when is_list(line) do append(@name, line) end
  def append(agent, line) when is_list(line) do
    Agent.update agent, fn(log) -> [line | log] end
  end
end
