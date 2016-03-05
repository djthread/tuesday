defmodule Tuesday.User do
  use Tuesday.Web, :model

  @derive {Poison.Encoder, only: [
    :id, :name, :email, :is_admin, :shows]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :pwhash, :string
    field :is_admin, :boolean

    many_to_many :shows, Tuesday.Show, join_through: "shows_users"

    timestamps
  end

  @required_fields ~w(name email pwhash)a
  @optional_fields ~w()a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(user, params \\ :invalid) do
    user
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
