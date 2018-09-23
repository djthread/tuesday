defmodule Tuesday.Show do
  use Tuesday.Web, :model
  alias Tuesday.{Repo,Episode,Event}

  @derive {Poison.Encoder, only: [
    :id, :name, :slug, :hosted_by,
    :tiny_info, :short_info]}

  schema "shows" do
    field :name,           :string
    field :slug,           :string
    field :hosted_by,      :string
    field :recurring_note, :string
    field :tiny_info,      :string
    field :short_info,     :string
    field :full_info,      :string
    field :genre,          :string
    field :podcast_name,   :string

    has_many :events,   Event
    has_many :episodes, Episode

    many_to_many :users, Tuesday.User, join_through: "shows_users"

    timestamps()
  end

  @required_fields ~w(name slug)a
  @optional_fields ~w(name slug  hosted_by     recurring_note
                      tiny_info  short_info    full_info
                      genre      podcast_name  )a

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

  def info_changeset(show, params \\ :invalid) do
    show
    |> cast(params, ~w(hosted_by recurring_note tiny_info short_info full_info)a)
    |> validate_required(~w(tiny_info short_info)a)
  end

  def preload_a_month_of_episodes_and_events(shows) do
    shows
    |> Repo.preload(episodes: from(ep in Episode,
        where:    ep.record_date > ago(1, "month"),
        order_by: [desc: ep.number]
       ))
    |> Repo.preload(events: from(ev in Event,
        where:    ev.happens_on > ago(2, "day")
                    and ev.happens_on < from_now(1, "month"),
        order_by: ev.happens_on
       ))
  end

  def preload_episodes_and_events(show) do
    show
    |> Repo.preload(
      episodes: from(ep in Episode, order_by: [desc: ep.number])
    )
    |> Repo.preload(
      events: from(ev in Event,
        where:    ev.happens_on > ago(2, "day"),
        order_by: ev.happens_on
      )
    )
  end


  # iex(16)> u |> Tuesday.User.changeset(%{}) |> Ecto.Changeset.put_assoc(:shows, [s]) |> Tuesday.Repo.update!
  #
  # def create_show(params, user_name) do
  #   import Ecto.Query
  #   user = Tuesday.User |> where(name: ^user_name) |> Tuesday.Repo.one
  #
  #   %Tuesday.Show{name: "Techno Tuesday", slug: "techno-tuesday"})
  #   |> Repo.insert!
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
