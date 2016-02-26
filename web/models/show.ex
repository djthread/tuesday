defmodule Tuesday.Show do
  use Tuesday.Web, :model

  schema "shows" do
    field :name, :string

    many_to_many :users, User, join_through: "shows_users"

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
