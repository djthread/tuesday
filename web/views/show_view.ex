defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
    require Logger

  def render("show.json", %{show: show}) do
    %{show:
      %{id:         show.id,
        name:       show.name,
        slug:       show.slug,
        tiny_info:  show.tiny_info,
        short_info: show.short_info,
        full_info:  show.full_info,
        episodes:   render_many(
          show.episodes, Tuesday.EpisodeView, "show.json")
      }
    }
  end
end
