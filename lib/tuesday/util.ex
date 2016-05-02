defmodule Tuesday.Util do
  use Calendar

  @secret :tuesday
          |> Application.get_env(Tuesday.Endpoint)
          |> Keyword.get(:auth_secret)

  def podcast_path_by_slug(slug) do
    "/srv/http/impulse/impulse-app/download/" <> slug
  end

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

  def update_podcast_feed(show) do
    Tuesday.ShowView
    |> Phoenix.View.render("feed.xml", show: show)
    |> IO.inspect
  end

  def bytes_by_slug_and_filename(show, filename) do
    path = podcast_path_by_slug(show.slug)

    case path |> Path.join(filename) |> File.stat do
      {:ok, %File.Stat{size: size}} -> size
      _                             -> nil
    end
  end
end
