use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :tuesday, Tuesday.Web.Endpoint,
  http: [port: 4091],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
    cd: Path.expand("../assets", __DIR__)]],
  auth_secret: "U(*(LO&F$YDC>PUD$#&*(YD$#@"

# Watch static and templates for browser reloading.
config :tuesday, Tuesday.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/tuesday/web/views/.*(ex)$},
      ~r{lib/tuesday/web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
# config :tuesday, Tuesday.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "tuesday_test",
#   hostname: "localhost",
#   pool_size: 10

config :tuesday, :podcast_paths, %{
  "wobblehead-radio" => "/Users/thread/Desktop/impulse/thread-episodes",
  "techno-tuesday"   => "/Users/thread/Desktop/impulse/thread-episodes"
}

config :tuesday, :photo_watch_dirs, [
  "/home/thread/test"
]

# config :tuesday, :piwigo_watched_dir,

import_config "dev.secret.exs"
