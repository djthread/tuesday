defmodule Tuesday.EpisodeView do
  use Tuesday.Web, :view
  import Tuesday.Util, only: [bytes_by_slug_and_filename: 1]
  import Calendar.Date.Format, only: [iso8601: 1]

  def render("show.json", %{episode: episode}) do
    %{id:          episode.id,
      number:      episode.number,
      title:       episode.title,
      record_date: episode.record_date,
      posted_on:   episode.inserted_at |> iso8601,
      filename:    episode.filename,
      description: episode.description || "",
      show_id:     episode.show_id,
      bytes:       bytes_by_slug_and_filename(episode) || 0
      # inserted_at: episode.inserted_at,
      # timestamp:   episode.inserted_at |> DateTime.Format.rfc850,
    }
  end

  def list(episodes) do
    Enum.map(episodes, fn(ep) ->
      render("show.json", episode: ep)
    end)
  end
end
