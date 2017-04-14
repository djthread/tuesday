defmodule Tuesday.Web.AjaxController do
  use Tuesday.Web, :controller

  @note "You must enter your public IP address here!"

  def myip(conn, _params) do
    ip =
      conn
      |> get_req_header("x-real-ip")
      |> case do
        [] -> @note
        list -> list |> hd
      end

    json conn, %{ip: ip}
  end
end
