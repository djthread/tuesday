defmodule Tuesday.InstagramChannel do
  use Tuesday.Web, :channel
  alias Tuesday.InstagramWorker

  def join("instagram", _params, socket) do
    {:ok, socket}
  end

  def handle_in("last_four", %{}, socket) do
    photos = InstagramWorker.photos()

    ret = %{
      last_four: photos |> Enum.take(4),
      total:     length(photos)
    }

    {:reply, {:ok, ret}, socket}
  end

  def handle_in("rest", %{}, socket) do
    photos = InstagramWorker.photos()

    ret = %{
      rest: photos |> Enum.slice(4..-1)
    }

    {:reply, {:ok, ret}, socket}
  end
end
