defmodule Tuesday.PhotoWatcher do
  @moduledoc """
  Watches for new photos being uploaded and adds them to piwigo,
  then refreshes PhotoWorker.
  """

  use ExFSWatch, dirs:
    Application.get_env(:tuesday, :photo_watch_dirs)

  require Logger

  @limit 12_000_000
  @exts  ~w(jpg JPG jpeg JPEG png PNG gif GIF)

  def callback(file_path, [:modified, :closed]), do: trigger file_path
  def callback(file_path, [:renamed]),           do: trigger file_path
  def callback(file_path, events) do
    Logger.info("exfswatch callback " <> file_path <> inspect(events))
  end

  defp trigger(file_path) do
    with %File.Stat{size: size} <- File.stat!(file_path),
         true                   <- size > 0 and size < @limit,
         [^file_path, ext]      <- Regex.run(~r/.*\.(\w+)$/, file_path),
         true                   <- ext in @exts,
         :ok                    <- Tuesday.PiwigoWorker.upload(file_path)
    do
      Tuesday.PhotoWorker.refresh
    end
  end
end
