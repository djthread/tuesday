defmodule Tuesday.ShowView do
  use Tuesday.Web, :view

  def render("show_episodes.json", %{show: show}) do
    %{show: %{
        name:     show.name,
        slug:     show.slug,
        episodes: render_many(
          show.episodes, Tuesday.ShowView, "episode.json")
      }
    }
  end

  def render("episode.json", %{episode: episode}) do
    %{id:          episode.id,
      number:      episode.number,
      title:       episode.title,
      record_date: episode.record_date,
      filename:    episode.filename,
      description: episode.description
    }
  end
end
