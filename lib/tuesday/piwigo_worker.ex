defmodule Tuesday.PiwigoWorker do
  @moduledoc """
  Interacts with the Piwigo gallery
  """

  use GenServer

  require Logger

  @name         __MODULE__
  @piwigo_ws    Application.get_env :tuesday, :piwigo_ws
  @piwigo_user  Application.get_env :tuesday, :piwigo_username
  @piwigo_pass  Application.get_env :tuesday, :piwigo_password
  @piwigo_catid Application.get_env :tuesday, :piwigo_catid

  def start_link() do
    opts = []
    |> Keyword.put_new(:name, @name)

    GenServer.start_link(@name, %{}, opts)
  end

  def upload(file_path) do
    GenServer.call @name, {:upload, file_path}
  end

  def init(state = %{}) do
    {:ok, state |> do_login}
  end

  def handle_call({:upload, file_path}, _from, state) do
    status = do_upload(file_path, state)
    {:reply, status, state}
  end

  defp do_upload(
    file_path, state = %{token: token, id: id}, last_try \\ false)
  do
    post = [ {"pwg_token", token},
             {"name",      file_path |> Path.split |> List.last},
             {"category",  @piwigo_catid},
             {:file,       file_path} ]

    headers = %{"Cookie" => "pwg_id=#{id}"}

    "pwg.images.upload"
    |> piwigo_url
    |> HTTPoison.post!({:multipart, post}, headers)
    |> handle_upload_result(state, file_path, last_try)
  end

  defp do_login(state) when is_map(state) do
    post = [ {:username, @piwigo_user},
             {:password, @piwigo_pass} ]

    pwg_id =
      "pwg.session.login"
      |> piwigo_url
      |> HTTPoison.post!({:form, post})
      |> login_resp_to_pwg_id

    pwg_token = pwg_id |> pwg_id_to_pwg_token

    state
    |> Map.put(:id, pwg_id)
    |> Map.put(:token, pwg_token)
  end

  defp pwg_id_to_pwg_token(pwg_id) do
    "pwg.session.getStatus"
    |> piwigo_url
    |> HTTPoison.get!(%{"Cookie" => "pwg_id=#{pwg_id}"})
    |> get_status_resp_to_pwg_token
  end

  defp login_resp_to_pwg_id(
    %HTTPoison.Response{status_code: 200, headers: headers})
  do
    headers
    |> Enum.filter(fn({header, v}) -> 
      header == "Set-Cookie" and String.starts_with?(v, "pwg_id=")
    end)
    |> hd
    |> elem(1)
    |> fn(s) -> Regex.replace(~r/(^pwg_id=|;.*$)/, s, "") end.()
  end

  def get_status_resp_to_pwg_token(
    %HTTPoison.Response{status_code: 200, body: body})
  do
    body
    |> Floki.find("pwg_token")
    |> fn([{"pwg_token", [], [token]}]) -> token end.()
  end

  defp piwigo_url(method = "pwg." <> _) do
    "#{@piwigo_ws}?format=rest&method=#{method}"
  end

  defp handle_upload_result(
    res = %HTTPoison.Response{status_code: status},
    state, file_path, last_try)
  do
    case status do
      200 -> :ok
      _ ->
        case last_try do
          true -> :error
          _ ->
            state = do_login(state)
            do_upload(file_path, state, true)
        end
    end
  end

end
