defmodule Tuesday.User do
  use Tuesday.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :pwhash, :string

    many_to_many :shows, Show, join_through: "shows_users"

    timestamps
  end

  @required_fields ~w(name email pwhash)
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
