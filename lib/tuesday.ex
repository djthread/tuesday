defmodule Tuesday do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Tuesday.Endpoint, []),
      supervisor(Tuesday.Repo, []),
      supervisor(Tuesday.ChatLog, []),
      supervisor(Tuesday.InstagramWorker, []),
      supervisor(Tuesday.StatWorker, []),
      # supervisor(Tuesday.PhotoWorker, []),
      # supervisor(Tuesday.PiwigoWorker, [])
    ]

    opts = [strategy: :one_for_one, name: Tuesday.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Tuesday.Endpoint.config_change(changed, removed)
    :ok
  end
end
