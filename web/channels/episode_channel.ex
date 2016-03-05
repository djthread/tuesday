defmodule Tuesday.EpisodeChannel do
  use Tuesday.Web, :channel

  def join("episode", _, socket) do
    Logger.info "joined episode"
    {:ok, socket}
  end

  def handle_in("shows", _msg, socket) do
    shows = Show |> Repo.all

    {:reply, {:ok, %{shows: shows}}, socket}
  end

  def handle_in("episodes", %{"slug" => slug, "page" => pageno}, socket) do
    q = from e in Episode,
        join:    s in Show,
        where:   s.slug == ^slug,
        preload: [show: s]

    {:reply, {:ok, %{episodes: q |> Repo.all}}, socket}
  end
end
