defmodule Tuesday.PhotosChannel do
  use Tuesday.Web, :channel
  alias Tuesday.PhotoWorker

  def join("photos", _params, socket) do
    send(self, :refresh_photos)
    {:ok, socket}
  end

  def handle_info(:refresh_photos, socket) do
    push_photos socket
    {:noreply, socket}
  end

  defp push_photos(socket) do
    push socket, "refresh", PhotoWorker.photos
  end
end
