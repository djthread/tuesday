defmodule Tuesday.Show do
  use Tuesday.Web, :model

  @derive {Poison.Encoder, only: [
    :id, :name, :slug]}

  schema "shows" do
    field :name, :string
    field :slug, :string

    has_many :episodes, Tuesday.Episode

    many_to_many :users, Tuesday.User, join_through: "shows_users"

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w()

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

  # iex(16)> u |> Tuesday.User.changeset(%{}) |> Ecto.Changeset.put_assoc(:shows, [s]) |> Tuesday.Repo.update!
  #
  # def create_show(params, user_name) do
  #   import Ecto.Query
  #   user = Tuesday.User |> where(name: ^user_name) |> Tuesday.Repo.one
  #
  #   Repo.insert!(%Tuesday.Show{name: "Techno Tuesday", slug: "techno-tuesday"})
  #   |> put_assoc
  #   # changeset(%Tuesday.Show{}, params)
  #   # |> put_assoc(:users, [user])
  #
  #   # import Ecto.Query
  #   # user = Tuesday.User |> where(name: ^user_name) |> Tuesday.Repo.one
  #   #
  #   # %Tuesday.Show{name: name, slug: slug}
  #   # |> put_assoc(:users, [user])
  #   # |> Tuesday.Repo.insert!
  # end
end
