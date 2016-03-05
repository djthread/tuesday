defmodule Tuesday.AdminChannel do
  use Tuesday.Web, :channel

  def join("admin", %{"name" => name, "pass" => pass}, socket) do
    user =
      User
      |> where(name: ^name, pwhash: ^hash(pass))
      |> Repo.one
      |> Repo.preload(:shows)

    case user do
      %User{} ->
        {:ok, socket |> assign(:user, user)}
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
end
