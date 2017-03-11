defmodule Tuesday.InstagramChannel do
  use Tuesday.Web, :channel
  alias Tuesday.InstagramWorker

  def join("instagram", _params, socket) do
    # send(self(), :last_four)
    {:ok, socket}
  end

  def handle_call(:last_four, socket) do
    {:reply, InstagramWorker.last_four() |> IO.inspect, socket}
  end
  # def handle_info(:last_four, socket) do
  #   push socket, "last_four", InstagramWorker.last_four
  #   {:noreply, socket}
  # end

  def handle_call(:all_photos, socket) do
    {:reply, InstagramWorker.all_photos(), socket}
  end
end
