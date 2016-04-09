defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
  alias Calendar.DateTime

  def render("show.json", %{show: show}) do
    episodes =
      Enum.map show.episodes, fn(ep) ->
        Tuesday.EpisodeView
        |> render("show.json", episode: ep, show: show)
      end

    %{show:
      %{id:         show.id,
        name:       show.name,
        slug:       show.slug,
        tiny_info:  show.tiny_info,
        short_info: show.short_info,
        full_info:  show.full_info,
        episodes:   episodes
      }
    }
  end

  def render("feed.xml", %{show: show}) do
    render("feed.xml", %{
      show:      show,
      timestamp: DateTime.now_utc |> DateTime.Format.rfc850
    })
  end
end
