defmodule Tuesday.Web.PokeController do
  use Tuesday.Web, :controller
  alias Tuesday.{User, Show}
  alias Tuesday.ShowView
  import Ecto.Query

  @poke_pass Application.get_env :tuesday, :poke_password

  def poke(conn, params) do
    {status, ret} =
      if params["password"] == @poke_pass do
        # Fire & forget
        Task.start(&Tuesday.InstagramWorker.refresh/0)

        {200, %{status: :ok}}
      else
        {403, %{status: :forbidden}}
      end

    conn
    |> put_status(status)
    |> json(ret)
  end
end
