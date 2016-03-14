defmodule Tuesday.AdminChannel do
  use Tuesday.Web, :channel
  require Logger

  def join("admin", %{"name" => name, "pass" => pass}, socket) do
    user =
      User
      |> where(name: ^name, pwhash: ^hash(pass))
      |> Repo.one

    case user do
      %User{} ->
        {:ok, assign(socket, :user, user |> Repo.preload(:shows))}
      _ ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("whoami", _msg, socket) do
    {:reply, {:ok, socket.assigns[:user]}, socket}
  end

  def handle_in("show", %{"id" => show_id}, socket)
  when is_integer(show_id)
  do
    show =
      Show
      |> where(id: ^show_id)
      |> Repo.one
      |> Repo.preload(:episodes)

    {:reply, {:ok, %{show: show, episodes: show.episodes}}, socket}
  end

  def handle_in("save_episode", %{"episode" => ep, "show_id" => show_id}, socket) do
    Logger.info "got ep: " <> inspect(ep)

    episode = 
      with show = %Show{} <- Show
                             |> where(id: ^show_id)
                             |> Repo.one,
                  episode <- %Episode{
                               title: ep["title"]
                             }
                             |> Episode.changeset(%{})
                             |> IO.inspect
                             |> Ecto.Changeset.put_assoc(:show, show),
        do: episode

    Logger.info "save_episode " <> inspect(episode)
    {:reply, {:ok, episode}, socket}
  end

  # def handle_id("episodes", %{"show_id" => show_id}, socket)
  # when is_integer(show_id)
  # do
  #   episodes =
  #     Episode
  #     |> where(show
  # end
end
