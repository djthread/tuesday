defmodule Tuesday.ChatEntry do
  use Tuesday.Web, :model

  @derive {Poison.Encoder, only: [
    :nick,
    :body,
    :created_at
  ]}

  schema "chat_entries" do
    field :msg, :string
    field :nick, :string
    field :body, :string

    timestamps()
  end

  @required_fields ~w(msg)a
  @optional_fields ~w(nick body)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(entry, params \\ :invalid) do
    entry
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
  end
end
