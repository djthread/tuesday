defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
    require Logger

  def render("show_episodes.json", %{show: show}) do
    Logger.info "alright: " <> inspect(show.episodes)
    %{show:
      %{id:       show.id,
        name:     show.name,
        slug:     show.slug,
        episodes: render_many(
          show.episodes, Tuesday.EpisodeView, "show.json")
      }
    }
  end
end
