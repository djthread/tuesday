defmodule Tuesday.EpisodeTest do
  use Tuesday.ModelCase

  alias Tuesday.Episode

  @valid_attrs %{description: "some content", filename: "some content", number: 42, record_date: "2010-04-17", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end
