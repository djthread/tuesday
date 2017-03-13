defmodule Tuesday.ChatLogTest do
  use ExUnit.Case, async: true

  # test "stores a line of chat" do
  #   {:ok, agent} = Tuesday.ChatLog.start_link_multi
  #   assert Tuesday.ChatLog.lines(agent, 3) == []
  #
  #   Tuesday.ChatLog.append(agent, [event: "new:msg", data: "What up, dude?"])
  #   assert Tuesday.ChatLog.lines(agent, 3) == [
  #     [event: "new:msg", data: "What up, dude?"]
  #   ]
  # end
  #
  # test "stores three lines of chat" do
  #   {:ok, agent} = Tuesday.ChatLog.start_link_multi
  #   assert Tuesday.ChatLog.lines(agent, 3) == []
  #
  #   Tuesday.ChatLog.append(agent, [event: "new:msg", data: "one"])
  #   Tuesday.ChatLog.append(agent, [event: "new:msg", data: "two"])
  #   Tuesday.ChatLog.append(agent, [event: "new:msg", data: "three"])
  #   assert Tuesday.ChatLog.lines(agent, 3) == [
  #     [event: "new:msg", data: "one"],
  #     [event: "new:msg", data: "two"],
  #     [event: "new:msg", data: "three"]
  #   ]
  # end
end
