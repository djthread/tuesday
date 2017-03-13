defmodule Tuesday.UserListTest do
  use Tuesday.AcceptanceCase, async: true


  test "users have names", %{session: session} do
    first_employee =
      session
      |> visit("/users")
      |> find(Query.css(".dashboard"))
      |> all(Query.css(".user"))
      |> List.first
      |> find(Query.css(".user-name"))
      |> text

    assert first_employee == "Chris"
  end
end
