defmodule Tuesday.EpisodeView do
  use Tuesday.Web, :view

  def render("index.json", %{episodes: episodes}) do
    %{data: render_many(episodes, Tuesday.EpisodeView, "episode.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{data: render_one(episode, Tuesday.EpisodeView, "episode.json")}
  end
end
