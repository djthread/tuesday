defmodule Tuesday.ShowView do
  use Tuesday.Web, :view
  alias Calendar.DateTime
  alias Tuesday.{EpisodeView,EventView}

  def render("new.json",
    %{episodes: episodes, events: events})
  do
    %{episodes: EpisodeView.list(episodes),
      events:   EventView.list(events)
    }
  end

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
      case params[:full] do  # deprecated
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
          Map.put(map, :episodes, EpisodeView.list(show))
        _ ->
          map
      end
    end.()
    |> fn(map) ->  # add events, if provided
      case show.events do
        evs when is_list(evs) ->
          Map.put(map, :events, EventView.list(evs))
        _ ->
          map
      end
    end.()
  end

  def render("show_detail.json", params = %{show: show}) do
    %{short_info: show.short_info,
      full_info:  show.full_info
    }
  end

  def render("feed.xml", %{show: show}) do
    render("feed.xml", %{
      show:      show,
      timestamp: DateTime.now_utc |> DateTime.Format.rfc850
    })
  end

end
