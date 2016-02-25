defmodule Tuesday.Episode do
  use Tuesday.Web, :model

  schema "episodes" do
    field :number, :integer
    field :title, :string
    field :record_date, Ecto.Date
    field :filename, :string
    field :description, :string

    timestamps
  end

  @required_fields ~w(number title record_date filename description)
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
