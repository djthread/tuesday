defmodule Tuesday.EpisodeView do
  use Tuesday.Web, :view
  require Logger

  def render("index.json", %{episodes: episodes}) do
    %{data: render_many(episodes, Tuesday.EpisodeView, "episode.json")}
  end

  # def render("show.json", %{episode: episode}) do
  #   %{data: render_one(episode, Tuesday.EpisodeView, "episode.json")}
  # end

  def render("show.json", %{episode: episode}) do
    %{id:          episode.id,
      number:      episode.number,
      title:       episode.title,
      record_date: episode.record_date,
      filename:    episode.filename,
      description: episode.description,
      show_id:     episode.show_id
    }
  end
end
