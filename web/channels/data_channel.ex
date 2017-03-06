defmodule Tuesday.DataChannel do
  use Tuesday.Web, :channel
  import Phoenix.View, only: [render: 3]
  alias Tuesday.{ShowView, EpisodeView}
  require Logger

  def join("data", _params, socket) do
    {:ok, socket}
  end

  def handle_in("shows", _msg, socket) do
    Show
    |> Repo.all
    |> fn(shows) ->
      Enum.map shows, fn(show) ->
        render(ShowView, "show.json", show: show)
      end
    end.()
    |> fn(shows) ->
      {:reply, {:ok, %{shows: shows}}, socket}
    end.()
  end

  # get the last 5 episodes and the next 5 events
  def handle_in("new", _msg, socket) do
    episodes =
      Repo.all from ep in Episode,
        where:    ep.record_date > ago(1, "month"),
        order_by: [desc: ep.number],
        limit:    5,
        preload:  [:show]

    events = 
      Repo.all from ev in Event,
        where:    ev.happens_on > ago(2, "day"),
        order_by: ev.happens_on,
        limit:    5

    { :reply,
      {:ok, render(ShowView, "new.json", %{
        episodes: episodes,
        events:   events
      })},
      socket
    }
  end

  def handle_in("show", %{"slug" => slug}, socket) do
    Show
    |> where(slug: ^slug)
    |> Repo.one
    # |> Show.preload_episodes_and_events
    |> fn(show) ->
      render(ShowView, "show.json", show: show, full: true)
    end.()
    |> fn(show) ->
      {:reply, {:ok, %{show: show}}, socket}
    end.()
  end

  def handle_in("episode", %{"slug" => slug, "num" => num}, socket)
  when is_number(num)
  do
    Show
    |> where(slug: ^slug)
    |> Repo.one
    |> Repo.preload(episodes: from(ep in Episode, where: ep.number == ^num))
    |> fn(show = %Show{episodes: [ep | _]}) ->
      render(EpisodeView, "show.json", episode: ep, show: show)
    end.()
    |> fn(ep) ->
      {:reply, {:ok, %{episode: ep}}, socket}
    end.()
  end

  # def handle_in("episodes", %{"slug" => slug, "page" => page}, socket) do
  #   listing =
  #     Episode
  #     |> join(s in Show)
  #     |> where(s.slug == ^slug)
  #     |> preload(show: s)
  #     |> Repo.paginate(page: page)
  #   # q = from e in Episode,
  #   #     join:    s in Show,
  #   #     where:   s.slug == ^slug,
  #   #     preload: [show: s]
  #   ret =
  #     %{episodes:      listing.entries,
  #       page_number:   listing.page_number,
  #       page_size:     listing.page_size,
  #       total_pages:   listing.total_pages,
  #       total_entries: listing.total_entries
  #     }
  #
  #   {:reply, {:ok, ret}, socket}
  # end
  #

  def handle_in("episodes", params, socket) do
    # page =
    #   case String.to_integer(params["page"]) do
    #   if params["page"] whe
    #     do: pg else: 1

    # listing =
    #   Episode
    #   |> fn(q) ->
    #     case params["show_id"] do
    #       id when is_integer(id) ->
    #         fn(q) -> q
    #           |> join(:left, [e], s in Show,
    #                   s.id == e.show_id)
    #           |> preload(show: s)
    #           |> select([s, e], {s, e})
    #         end
    #       _ -> fn(q) -> q end
    #     end
    #   end.()
    #   |> order_by(desc: :posted_on)
    #   |> Repo.paginate(params)

    listing = Repo.paginate(
      # case params["show_id"] do
      #   id when is_integer(id) ->
      #     from e in "episodes",
      #       where: e.show_id == ^id
      #       order_by: [desc: e.posted_on],
      #   _ ->
      #     from e in "episodes",
      #       order_by: [desc: e.posted_on]
      # end

      from e in Episode,
        order_by: [desc: e.inserted_at]

      )

    entries =
      Tuesday.EpisodeView.list(listing.entries)
      # Enum.map(listing.entries, fn(sh) ->
      #    Phoenix.View.render(Tuesday.EpisodeView, "show.json")
      # end)
      # Enum.map(listing.entries, fn(ep) ->
      #   ep
      #   |> Map.delete(:__struct__)
      #   |> Map.delete(:__meta__)
      #   |> Map.delete(:show)
      #   |> Map.delete(:user)
      #   |> IO.inspect
      # end)

    ret =
      %{entries: entries,
        pager: %{
          page_number:   listing.page_number,
          page_size:     listing.page_size,
          total_pages:   listing.total_pages,
          total_entries: listing.total_entries
        }
      }

    {:reply, {:ok, ret}, socket}
  end
    # q = from e in Episode,
    #     join:    s in Show,
    #     where:   s.slug == ^slug,
    #     preload: [show: s]

  # |> MyApp.Repo.paginate(page: 2, page_size: 5)
  # render conn, :index,
  #   people: page.entries,
  #   page_number: page.page_number,
  #   page_size: page.page_size,
  #   total_pages: page.total_pages,
  #   total_entries: page.total_entries
  # 
  # 

  """
  def handle_in("whoami", _msg, socket) do
    {:reply, {:ok, socket.assigns[:user]}, socket}
  end

  def handle_in("show", %{"id" => show_id}, socket)
  when is_integer(show_id)
  do
    Show
    |> where(id: ^show_id)
    |> Repo.one
    |> Repo.preload(:episodes)
    |> (fn(sh) ->
         Phoenix.View.render(
           Tuesday.ShowView, "show_episodes.json", show: sh)
       end).()
    |> (fn(show) ->
         {:reply, {:ok, show}, socket}
       end).()
  end

  def handle_in("save_episode",
    %{"episode" => ep = %{"show_id" => show_id}}, socket)
  do
    Logger.info "got ep: " <> inspect(ep)

    episode = 
      with          show <- Show |> where(id: ^show_id) |> Repo.one,
               changeset <- %Episode{}
                            |> Episode.changeset(ep)
                            |> Ecto.Changeset.put_assoc(:show, show),
          {:ok, episode} <- fn(cs) ->
                              case ep["id"] do
                                nil -> cs |> Repo.insert
                                _   -> cs |> Repo.update!
                              end
                            end.(changeset),
        do: episode

    rendered = Phoenix.View.render(
      Tuesday.EpisodeView, "show.json", episode: episode)

    Logger.info "save_episode " <> inspect(rendered)
    {:reply, {:ok, %{episode: rendered}}, socket}
  end

  # def handle_id("episodes", %{"show_id" => show_id}, socket)
  # when is_integer(show_id)
  # do
  #   episodes =
  #     Episode
  #     |> where(show
  # end
  """
end
