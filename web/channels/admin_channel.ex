defmodule Tuesday.AdminChannel do
  use Tuesday.Web, :channel

  def join("admin", %{"name" => name, "pass" => pass}, socket) do
    user =
      where(User, name: ^name, pwhash: ^hash(pass))
      |> Repo.first
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

end
