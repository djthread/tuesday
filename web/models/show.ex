defmodule Tuesday.Show do
  use Tuesday.Web, :model

  @derive {Poison.Encoder, only: [
    :id, :name, :slug, :users, :episodes]}

  schema "shows" do
    field :name, :string
    field :slug, :string

    has_many :episodes, Tuesday.Episode

    many_to_many :users, Tuesday.User, join_through: "shows_users"

    timestamps
  end

  @required_fields ~w(name slug)a
  @optional_fields ~w()a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(show, params \\ :invalid) do
    show
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
  end
end
