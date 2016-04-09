defmodule Tuesday.EpisodeView do
  use Tuesday.Web, :view
  import Tuesday.Util
  alias Calendar.DateTime

  # def render("index.json", %{episodes: episodes}) do
  #   %{data: render_many(episodes, Tuesday.EpisodeView, "episode.json")}
  # end

  # def render("show.json", %{episode: episode}) do
  #   %{data: render_one(episode, Tuesday.EpisodeView, "episode.json")}
  # end

  def render("show.json", %{episode: episode, show: show}) do
    %{id:          episode.id,
      number:      episode.number,
      title:       episode.title,
      record_date: episode.record_date,
      inserted_at: episode.inserted_at,
      filename:    episode.filename,
      description: episode.description,
      show_id:     episode.show_id,
      timestamp:   episode.inserted_at |> DateTime.Format.rfc850,
      bytes:       bytes_by_slug_and_filename(show, episode.filename)
    }
  end
end
