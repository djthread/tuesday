defmodule Tuesday.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Tuesday.Web.Endpoint, []),
      supervisor(Tuesday.Repo, []),
      supervisor(Tuesday.ChatLog, []),
      worker(Tuesday.InstagramWorker, []),
      # supervisor(Tuesday.StatWorker, []),
      # supervisor(Tuesday.PhotoWorker, []),
      # supervisor(Tuesday.PiwigoWorker, [])
    ]

    opts = [strategy: :one_for_one, name: Tuesday.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Tuesday.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
