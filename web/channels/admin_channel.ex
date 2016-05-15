defmodule Tuesday.AdminChannel do
  use Tuesday.Web, :channel
  import Phoenix.View, only: [render: 3]
  alias Tuesday.{MP3, Util}
  alias Tuesday.ShowView
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
    |> Show.preload_episodes_and_events
    |> fn(show) ->
         render(ShowView, "show.json", show: show, full: true)
       end.()
    |> fn(show) ->
         {:reply, {:ok, show}, socket}
       end.()
  end

  def handle_in("save_episode",
    %{"episode" => ep = %{"id" => id, "show_id" => show_id}}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      dbshow ->
        Episode
        |> where(show_id: ^dbshow.id)
        |> Repo.get!(id)
        |> Episode.changeset(ep)
        |> Repo.update
        |> handle_save_result(dbshow, socket)
    end
  end

  def handle_in("save_episode",
    %{"episode" => ep = %{"show_id" => show_id}}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      dbshow ->
        ^show_id = dbshow.id  # make sure episode belongs to show
        %Episode{}
        |> Episode.changeset(ep)
        |> Ecto.Changeset.put_assoc(:show, dbshow)
        |> Repo.insert
        |> handle_save_result(dbshow, socket)
    end
  end


  def handle_in("save_event",
    %{"event" => ep = %{"id" => id, "show_id" => show_id}}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      dbshow ->
        Event
        |> where(show_id: ^dbshow.id)
        |> Repo.get!(id)
        |> Event.changeset(ep)
        |> Repo.update
        |> handle_save_result(dbshow, socket)
    end
  end

  def handle_in("save_event",
    %{"event" => ep = %{"show_id" => show_id}}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      dbshow ->
        ^show_id = dbshow.id  # make sure event belongs to show
        %Event{}
        |> Event.changeset(ep)
        |> Ecto.Changeset.put_assoc(:show, dbshow)
        |> Repo.insert
        |> handle_save_result(dbshow, socket)
    end
  end

  def handle_in("save_info",
    %{"show" => show = %{"id" => id}}, socket)
  do
    case show_owned_by_user(id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      dbshow ->
        ^id = dbshow.id  # make sure event belongs to show
        dbshow
        |> Show.info_changeset(show)
        |> Repo.update
        |> handle_save_result(nil, socket)
    end
  end

  def handle_in("read_tags", %{"id" => show_id, "filename" => filename}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      %{slug: slug} ->
        slug
        |> Util.podcast_path_by_slug
        |> fn(path) -> MP3.get_meta(path <> "/" <> filename) end.()
        |> fn(meta) -> {:reply, {:ok, meta}, socket} end.()
    end
  end


  defp handle_save_result({:ok, episode = %Tuesday.Episode{}}, show, socket) do
    # Tuesday.EpisodeView
    # |> Phoenix.View.render("show.json", episode: episode, show: show)
    # |> fn(json) -> {:reply, {:ok, json}, socket} end.()
    do_handle_save_result(
      Tuesday.EpisodeView, "show.json", :ok, socket, episode: episode, show: show)
  end

  defp handle_save_result({:ok, event = %Tuesday.Event{}}, show, socket) do
    # Tuesday.EventView
    # |> Phoenix.View.render("show.json", event: event)
    # |> fn(json) -> {:reply, {:ok, json}, socket} end.()
    do_handle_save_result(
      Tuesday.EventView, "show.json", :ok, socket, event: event)
  end

  defp handle_save_result({:ok, show = %Tuesday.Show{}}, _show, socket) do
    show = show |> Show.preload_episodes_and_events
    # Tuesday.ShowView
    # |> Phoenix.View.render("show.json", show: show)
    # |> fn(json) -> {:reply, {:ok, json}, socket} end.()
    do_handle_save_result(
      Tuesday.ShowView, "show.json", :ok, socket, show: show)
  end

  defp handle_save_result({:error, changeset}, _show, socket) do
    # Tuesday.ChangesetView
    # |> Phoenix.View.render("error.json", changeset: changeset)
    # |> fn(json) -> {:reply, {:error, json}, socket} end.()
    do_handle_save_result(
      Tuesday.ChangesetView, "error.json", :error, socket, changeset: changeset)
  end


  defp do_handle_save_result(view, name, reply_atom, socket, vars) do
    view
    |> Phoenix.View.render(name, vars)
    |> fn(json) -> {:reply, {reply_atom, json}, socket} end.()
  end


  defp not_authorized(socket) do
    {:reply, {:error, "Not Authorized"}, socket}
  end


  defp show_owned_by_user(show_id, user_id) do
    show = Show |> where(id: ^show_id) |> Repo.one |> Repo.preload(:users)
    if Enum.find(show.users, &(&1.id == user_id)) do
      show
    else
      nil
    end
  end

  # def handle_id("episodes", %{"show_id" => show_id}, socket)
  # when is_integer(show_id)
  # do
  #   episodes =
  #     Episode
  #     |> where(show
  # end
end
