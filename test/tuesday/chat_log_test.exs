defmodule Tuesday.ChatLogTest do
  use ExUnit.Case, async: true

  test "stores a line of chat" do
    {:ok, agent} = Tuesday.ChatLog.start_link_multi
    assert Tuesday.ChatLog.lines(agent, 3) == []

    Tuesday.ChatLog.append(agent, "What up, dude?")
    assert Tuesday.ChatLog.lines(agent, 3) == [
      "What up, dude?"
    ]
  end

  test "stores three lines of chat" do
    {:ok, agent} = Tuesday.ChatLog.start_link_multi
    assert Tuesday.ChatLog.lines(agent, 3) == []

    Tuesday.ChatLog.append(agent, "one")
    Tuesday.ChatLog.append(agent, "two")
    Tuesday.ChatLog.append(agent, "three")
    assert Tuesday.ChatLog.lines(agent, 3) == [
      "one", "two", "three"
    ]
  end
end
