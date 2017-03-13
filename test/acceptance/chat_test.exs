defmodule Tuesday.UserListTest do
  use Tuesday.AcceptanceCase, async: true

  @name_field Query.text_field("name")
  @text_field Query.text_field("msg")
  @submit     Query.css(".submit")

  test "users have names", %{session: session} do
    session
    |> visit("/")
    |> find(@text_field)
    |> IO.inspect

    # first_employee =
    #   session
    #   |> visit("/")
    #   |> find(Query.css(".dashboard"))
    #   |> all(Query.css(".user"))
    #   |> List.first
    #   |> find(Query.css(".user-name"))
    #   |> text
    #
    # assert first_employee == "Chris"
  end

end
