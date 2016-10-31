defmodule Tuesday.Web.AdminController do
  use Tuesday.Web, :controller
  alias Tuesday.{User, Show}
  alias Tuesday.ShowView
  import Ecto.Query

  @api_pass Application.get_env :tuesday, :poke_password

  def poke(conn, params) do
    {status, ret} =
      case params["password"] == @api_pass do
        true ->
          # Fire & forget
          Task.start(&Tuesday.InstagramWorker.refresh/0)
          # Task.start(&Tuesday.PhotoWorker.refresh/0)

          {200, %{status: :ok}}
        _ ->
          {403, %{status: :forbidden}}
      end

    conn
    |> put_status(status)
    |> json(ret)
  end

  def auth(conn, %{"name" => name, "pass" => pass}) do
    case User.auth(name, pass) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> json(%{status: :ok})
      :error ->
        conn
        |> put_status(401)
        |> json(%{status: "Unauthorized"})
    end
  end

  def whoami(conn, _params) do
    user =
      conn
      |> Guardian.Plug.current_resource
      |> Repo.preload(:shows)

    conn |> json(user)
  end

  def show(conn, %{"id" => show_id}) do
    show =
      Show
      |> where(id: ^show_id)
      |> Repo.one
      |> Show.preload_episodes_and_events

    conn |> render(ShowView, "show.json", show: show, full: true)
  end

  def save_episode(conn, %{"episode" => ep = %{"id" => id, "show_id" => show_id}}) do
    user_id = Guardian.Plug.current_resource |> Map.get(:id)
    case show_owned_by_user(show_id, user_id) do
      nil -> not_authorized(conn)
      dbshow ->
        Episode
        |> where(show_id: ^dbshow.id)
        |> Repo.get!(id)
        |> Episode.changeset(ep)
        |> Repo.update
        |> passthru_and_maybe_write_tags(dbshow)
        |> handle_save_result(dbshow, conn)
    end
  end


  def unauthenticated(conn, params) do
    conn
    |> put_status(401)
    |> json(%{status: "Authentication required"})
  end


  defp handle_save_result({:ok, episode = %Tuesday.Episode{}}, show, conn) do
    do_handle_save_result(
      Tuesday.EpisodeView, "show.json", :ok, conn, episode: episode, show: show)
  end

  defp handle_save_result({:ok, event = %Tuesday.Event{}}, _show, conn) do
    do_handle_save_result(
      Tuesday.EventView, "show.json", :ok, conn, event: event)
  end

  defp handle_save_result({:ok, show = %Tuesday.Show{}}, _show, conn) do
    show = show |> Show.preload_episodes_and_events
    do_handle_save_result(
      Tuesday.ShowView, "show.json", :ok, conn, show: show)
  end

  defp handle_save_result({:error, changeset}, _show, conn) do
    do_handle_save_result(
      Tuesday.ChangesetView, "error.json", :error, conn, changeset: changeset)
  end


  defp do_handle_save_result(view, name, reply_atom, conn, vars) do
    conn
    |> render(Phoenix.View.render(name, vars))
    # view
    # |> Phoenix.View.render(name, vars)
    # |> fn(json) -> {:reply, {reply_atom, json}, conn} end.()
  end


  defp passthru_and_maybe_write_tags({:ok, event}, show) do
    MP3.write_tags_if_file_exists(event, show)
    {:ok, event}
  end
  defp passthru_and_maybe_write_tags(result, _show), do: result


  defp not_authorized(conn) do
    conn
    |> put_status(403)
    |> json(%{status: "Forbidden"})
  end


  defp show_owned_by_user(show_id, user_id) do
    show = Show |> where(id: ^show_id) |> Repo.one |> Repo.preload(:users)
    if Enum.find(show.users, &(&1.id == user_id)) do
      show
    else
      nil
    end
  end


  # alias Tuesday.Episode
  #
  # plug :scrub_params, "episode" when action in [:create, :update]
  #
  # def index(conn, _params) do
  #   episodes = Repo.all(Episode)
  #   render(conn, "index.json", episodes: episodes)
  # end
  #
  # def create(conn, %{"episode" => episode_params}) do
  #   changeset = Episode.changeset(%Episode{}, episode_params)
  #
  #   case Repo.insert(changeset) do
  #     {:ok, episode} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", episode_path(conn, :show, episode))
  #       |> render("show.json", episode: episode)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Tuesday.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end
  #
  # def show(conn, %{"id" => id}) do
  #   episode = Repo.get!(Episode, id)
  #   render(conn, "show.json", episode: episode)
  # end
  #
  # def update(conn, %{"id" => id, "episode" => episode_params}) do
  #   episode = Repo.get!(Episode, id)
  #   changeset = Episode.changeset(episode, episode_params)
  #
  #   case Repo.update(changeset) do
  #     {:ok, episode} ->
  #       render(conn, "show.json", episode: episode)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Tuesday.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   episode = Repo.get!(Episode, id)
  #
  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(episode)
  #
  #   send_resp(conn, :no_content, "")
  # end
end
