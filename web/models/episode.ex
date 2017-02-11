defmodule Tuesday.Episode do
  use Tuesday.Web, :model

  @derive {Poison.Encoder, only: [
    :id, :number, :title, :record_date, :filename,
    :description, :show, :user
  ]}

  schema "episodes" do
    field :number, :integer
    field :title, :string
    field :record_date, Ecto.Date
    field :filename, :string
    field :description, :string

    belongs_to :user, Tuesday.User
    belongs_to :show, Tuesday.Show

    timestamps()
  end

  @required_fields ~w(number title record_date filename)a
  @optional_fields ~w(number title record_date filename description)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(episode, params \\ :invalid) do
    episode
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:show)
  end
end
