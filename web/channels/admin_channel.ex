defmodule Tuesday.AdminChannel do
  use Tuesday.Web, :channel

  def join("admin", params, socket) do
    Logger.info inspect(params)
    {:ok, socket}
  end

  def handle_in(
    "admin:auth",
    [name: name, pwhash: pass],
    socket)
  do
    user = where(User, name: ^name, pwhash: ^hash(pass))
           |> Repo.first

    case user do
      %User{} ->
        {:reply, :ok, socket |> assign(:user, user)}
      _ ->
        {:reply, :error, socket}
    end
  end
end
