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
    |> Show.preload_episodes_and_events
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

  # def handle_in("episodes", %{"slug" => slug, "page" => pageno}, socket) do
  #   q = from e in Episode,
  #       join:    s in Show,
  #       where:   s.slug == ^slug,
  #       preload: [show: s]
  #
  #   {:reply, {:ok, %{episodes: q |> Repo.all}}, socket}
  # end

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
