defmodule Tuesday.PageController do
  use Tuesday.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def info(conn, _params) do
    url = "http://techtues.net/stat"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        count = body |> extract_count
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        count = "unknown"
      {:error, %HTTPoison.Error{reason: reason}} ->
        count = "unknown"
    end

    info = %{
      count: count
    }

    json conn, info
  end

  defp extract_count(body) do
    [_, count | _] = Regex.run(~r|<nclients>(\d+)</nclients>|, body)

    case count == "0" or count == "1" do
      true  -> "0"
      false -> count |> Integer.parse |> elem(0) |> :erlang.-(1) |> to_string
    end
  end
end
