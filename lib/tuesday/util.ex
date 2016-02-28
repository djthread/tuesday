defmodule Tuesday.Util do
  use Calendar

  @secret Application.get_env(:tuesday, Tuesday.Endpoint)
          |> Keyword.get(:auth_secret)

  def get_now do
    DateTime.now_utc |> DateTime.Format.unix
  end

  @doc """
  Hash a string, with salt.
  """
  def hash(str) when is_binary(str) do
    :crypto.hash(:sha256, str <> @secret)
    |> Base.encode64
  end

  def fake_socket(topic) do
    %Phoenix.Socket{
      # pid:       self,
      # router:    Tuesday.Router,
      topic:     topic,
      assigns:   [],
      transport: Phoenix.Transports.WebSocket
    }
  end
end
