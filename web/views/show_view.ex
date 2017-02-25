defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
  alias Calendar.DateTime

  @doc """
  Use param `full: true` to include short_info and full_info
  """
  def render("show.json", params = %{show: show}) do
    %{id:         show.id,
      name:       show.name,
      slug:       show.slug,
      tiny_info:  show.tiny_info,
    }
    |> Map.merge(
      case params[:full] do
        true ->
          %{ short_info: show.short_info,
             full_info:  show.full_info
          }
        _ ->
          %{}
      end
      )
    |> fn(map) ->  # add episodes, if provided
      case show.episodes do
        eps when is_list(eps) ->
          Map.put(map, :episodes,
            Enum.map(show.episodes, fn(ep) ->
              Tuesday.EpisodeView
              |> render("show.json", episode: ep, show: show)
            end)
          )
        _ ->
          map
      end
    end.()
    |> fn(map) ->  # add events, if provided
      case show.events do
        evs when is_list(evs) ->
          Map.put(map, :events,
            Enum.map(show.events, fn(ev) ->
              Tuesday.EventView
              |> render("show.json", event: ev)
            end)
          )
        _ ->
          map
      end
    end.()
  end

  def render("feed.xml", %{show: show}) do
    render("feed.xml", %{
      show:      show,
      timestamp: DateTime.now_utc |> DateTime.Format.rfc850
    })
  end
end
