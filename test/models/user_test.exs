defmodule Tuesday.UserTest do
  use Tuesday.ModelCase

  alias Tuesday.User

  @valid_attrs %{email: "some content", name: "some content", pwhash: "some content", show_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
