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
    Show
    |> where(id: ^show_id)
    |> Repo.one
    |> Repo.preload(:episodes)
    |> (fn(sh) ->
         Phoenix.View.render(Tuesday.ShowView, "show.json", show: sh)
       end).()
    |> (fn(show) ->
         {:reply, {:ok, show}, socket}
       end).()
  end

  def handle_in("save_episode",
    %{"episode" => ep = %{"id" => id, "show_id" => show_id}}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil ->
        {:reply, {:error, "Not Authorized"}, socket}
      show ->
        Episode
        |> Repo.get!(id)
        |> fn(e) -> show.id == e.show_id; e end.()
        |> Episode.changeset(ep)
        |> Repo.update
        |> handle_save_episode_result(socket)
    end
  end

  def handle_in("save_episode",
    %{"episode" => ep = %{"show_id" => show_id}}, socket)
  do
    case show = show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil ->
        {:reply, {:error, "Not Authorized"}, socket}
      show ->
        %Episode{}
        |> Episode.changeset(ep)
        |> fn(e) -> show.id == e.show_id; e end.()
        |> Ecto.Changeset.put_assoc(:show, show)
        |> Repo.insert
        |> handle_save_episode_result(socket)
    end
  end

  def handle_save_episode_result({:ok, episode}, socket) do
    Tuesday.EpisodeView
    |> Phoenix.View.render("show.json", episode: episode)
    |> fn(json) -> {:reply, {:ok, json}, socket} end.()
  end

  def handle_save_episode_result({:error, changeset}, socket) do
    Tuesday.ChangesetView
    |> Phoenix.View.render("error.json", changeset: changeset)
    |> fn(json) -> {:reply, {:error, json}, socket} end.()
  end

  defp show_owned_by_user(show_id, user_id) do
    show = Show |> where(id: ^show_id) |> Repo.one |> Repo.preload(:users)
    Enum.find(show.users, &(&1.id == user_id))
  end

  # def handle_id("episodes", %{"show_id" => show_id}, socket)
  # when is_integer(show_id)
  # do
  #   episodes =
  #     Episode
  #     |> where(show
  # end
end
