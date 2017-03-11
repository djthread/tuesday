defmodule Tuesday.InstagramChannel do
  use Tuesday.Web, :channel
  alias Tuesday.InstagramWorker

  def join("instagram", _params, socket) do
    # send(self(), :last_four)
    {:ok, socket}
  end

  def handle_in("last_four", %{}, socket) do
    IO.puts "YEA"
    {:reply, {:ok, InstagramWorker.last_four()}, socket}
  end
  # def handle_info(:last_four, socket) do
  #   push socket, "last_four", InstagramWorker.last_four
  #   {:noreply, socket}
  # end

  def handle_in("all_photos", %{}, socket) do
    {:reply, {:ok, InstagramWorker.all_photos()}, socket}
  end
end
