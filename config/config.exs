# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :tuesday, Tuesday.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "q65SZ5X4yWwBZvRmOIgDv3x5qg0CoIV1jmPRsYNVQkG/je1sJmo2Pxc8/hoFAJVo",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Tuesday.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :tuesday, :api_password, "test"  # used?

config :tuesday, :rtmp_stat_url,    "https://localhost:9077/stat"
config :tuesday, :icecast_stat_url, "http://impulsedetroit.net:8000/status-json.xsl"

config :tuesday, :piwigo_feed_url, "https://photos.impulsedetroit.net/ws.php?format=rest&method=pwg.categories.getImages&cat_id=5&per_page=4"
config :tuesday, :piwigo_ws, "https://photos.impulsedetroit.net/ws.php"
config :tuesday, :piwigo_catid, "5"

config :tuesday, ecto_repos: [Tuesday.Repo]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# This line was automatically added by ansible-elixir-stack setup script
# if System.get_env("SERVER") do
#   config :phoenix, :serve_endpoints, true
# end
