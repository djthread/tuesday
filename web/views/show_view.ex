defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
  alias Calendar.DateTime

  @doc """
  Use param `full: true` to include short_info and full_info
  """
  def render("show.json", params = %{show: show}) do
    episodes =
      Enum.map show.episodes, fn(ep) ->
        Tuesday.EpisodeView
        |> render("show.json", episode: ep, show: show)
      end

    events =
      Enum.map show.events, fn(ev) ->
        Tuesday.EventView
        |> render("show.json", event: ev, show: show)
      end

    %{id:         show.id,
      name:       show.name,
      slug:       show.slug,
      tiny_info:  show.tiny_info,
      episodes:   episodes,
      events:     events
    }
    |> Map.merge(
         case params[:full] do
           true -> %{
             short_info: show.short_info,
             full_info:  show.full_info
           }
           _ -> %{}
         end
       )
  end

  def render("feed.xml", %{show: show}) do
    render("feed.xml", %{
      show:      show,
      timestamp: DateTime.now_utc |> DateTime.Format.rfc850
    })
  end
end
