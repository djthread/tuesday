defmodule Tuesday.Web.AdminChannel do
  use Tuesday.Web, :channel
  import Phoenix.View, only: [render: 3]
  alias Tuesday.MP3
  alias Tuesday.Web.Util
  alias Tuesday.Web.{ShowView, EventView, EpisodeView, ChangesetView}
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

  @doc "Allow the client to get their own user data"
  def handle_in("whoami", _msg, socket) do
    {:reply, {:ok, socket.assigns[:user]}, socket}
  end

  @doc "Get show json"
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

  @doc "Save existing episode"
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
        |> passthru_and_maybe_write_tags(dbshow)
        |> handle_save_result(dbshow, socket)
    end
  end

  @doc "Save new episode"
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
        |> passthru_and_maybe_write_tags(dbshow)
        |> handle_save_result(dbshow, socket)
    end
  end


  @doc "Save existing event"
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

  @doc "Save new event"
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

  @doc "Save show info texts"
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

  @doc "Get ID3 json"
  def handle_in("read_tags", %{"id" => show_id, "filename" => filename}, socket)
  do
    case show_owned_by_user(show_id, socket.assigns[:user].id) do
      nil -> not_authorized(socket)
      %{slug: slug} ->
        slug
        |> Util.podcast_path_by_slug(filename)
        |> fn(full_filename) -> full_filename |> MP3.get_meta end.()
        |> fn(meta)          -> {:reply, {:ok, meta}, socket} end.()
    end
  end

  @doc "Start Facebook stream"
  def handle_in("stream_start", params, socket) do
    ret =
      System.cmd "/usr/bin/sudo", [
        "/usr/local/bin/nginx_rtmp_starter",
        "--url=" <> to_string(params["url"]),
        "--ip=" <> to_string(params["ip"])
      ]

    case ret do
      {"", 0} ->
        {:reply, {:ok, %{status: :ok}}, socket}
      {msg, code} ->
        Logger.error fn ->
          "Error restarting nginx with status #{code}: #{msg}"
        end

        {:reply, {:ok, %{status: :error}}, socket}
    end
  end


  defp passthru_and_maybe_write_tags({:ok, event}, show) do
    MP3.write_tags_if_file_exists(event, show)
    {:ok, event}
  end
  defp passthru_and_maybe_write_tags(result, _show), do: result


  defp handle_save_result({:ok, episode = %Tuesday.Episode{}}, show, socket) do
    do_handle_save_result(
      EpisodeView, "show.json", :ok, socket, episode: episode, show: show)
  end

  defp handle_save_result({:ok, event = %Tuesday.Event{}}, _show, socket) do
    do_handle_save_result(
      EventView, "show.json", :ok, socket, event: event)
  end

  defp handle_save_result({:ok, show = %Tuesday.Show{}}, _show, socket) do
    show = show |> Show.preload_episodes_and_events
    do_handle_save_result(
      ShowView, "show.json", :ok, socket, show: show)
  end

  defp handle_save_result({:error, changeset}, _show, socket) do
    do_handle_save_result(
      ChangesetView, "error.json", :error, socket, changeset: changeset)
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
