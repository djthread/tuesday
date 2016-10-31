defmodule Tuesday.User do
  use Tuesday.Web, :model
  import Tuesday.Auth, only: [hash: 1]
  import Ecto.Query, only: [where: 2]
  alias Tuesday.{User, Repo}

  @derive {Poison.Encoder, only: [
    :id, :name, :email, :is_admin, :shows]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :pwhash, :string
    field :is_admin, :boolean

    many_to_many :shows, Tuesday.Show, join_through: "shows_users"

    timestamps()
  end

  @required_fields ~w(name email pwhash)a
  @optional_fields ~w(name email pwhash is_admin)a

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

  def create(name, pass, email, admin? \\ false) do
    changeset = changeset(%Tuesday.User{}, %{
      "name"     => name,
      "pwhash"   => hash(pass),
      "email"    => email,
      "is_admin" => admin?
    })

    Tuesday.Repo.insert(changeset)
  end

  @type auth(String.t, String.t) :: {:ok, %Tuesday.User{}} | :error
  def auth(name, pass) do
    User
    |> where(name: ^name, pwhash: ^hash(pass))
    |> Repo.one
    |> case do
      user = %User{} -> {:ok, user}
      _ -> :error
    end
  end

  # u |> Ecto.build_assoc(:shows)
  #   |> Ecto.Changeset.cast(%{"name" => "", "slug" => ""}, req)
  #   |> Tuesday.Repo.insert

  # u |> Repo.preload(:shows)
  #   |> Ecto.Changeset.cast(%{}, [])
  #   |> Ecto.Changeset.put_assoc(:shows, [s])
  #   |> Repo.update
end
