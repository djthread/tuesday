defmodule Tuesday.Web.AjaxController do
  use Tuesday.Web, :controller

  def myip(conn, _params) do
    json conn, %{ip: conn |> get_req_header("x-real-ip") |> hd}
  end
end
