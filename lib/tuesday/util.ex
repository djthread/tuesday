defmodule Tuesday.Web.Util do
  @secret :tuesday
          |> Application.get_env(Tuesday.Web.Endpoint)
          |> Keyword.get(:auth_secret)

  @doc "Get the dir of episode mp3s, given a slug"
  def podcast_path_by_slug(slug, filename \\ nil) do
    # "/srv/http/impulse/impulse-app/download/" <> slug
    :tuesday
    |> Application.get_env(:podcast_paths)
    |> Map.get(slug)
    |> fn(path) ->
      case filename do
        nil  -> path
        file -> [path, file] |> Path.join
      end
    end.()
    # case slug do
    #   "techno-tuesday" -> "/srv/http/threadbox/dnbcast"
    # end
  end

  def get_now do
    DateTime.utc_now |> DateTime.to_unix
    # DateTime.now_utc |> DateTime.Format.unix
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

  # def bytes_by_slug_and_filename(episode) do
  #   episode.show.slug
  #   |> podcast_path_by_slug
  #   |> Path.join(episode.filename)
  #   |> File.stat 
  #   |> case do
  #     {:ok, %File.Stat{size: size}} -> size
  #     _                             -> nil
  #   end
  # end
end
