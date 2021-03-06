use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :tuesday, Tuesday.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4100],
  url: [host: "impulsedetroit.net", port: 80],
  check_origin: false,
  # watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
  #   cd: Path.expand("../assets", __DIR__)]],
  # [
  #   "https://impulsedetroit.net",
  #   "https://backstage.impulsedetroit.net",
  #   "https://techtues.net"
  # ],
  cache_static_manifest: "priv/static/manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version]

# Do not print debug messages in production
config :logger, level: :info

config :tuesday, :podcast_paths, %{
  "techno-tuesday"    => "/nextcloud_data/data/thread/files/techtues-episodes",
  "specials"          => "/nextcloud_data/data/thread/files/specials-episodes",
  "wobblehead-radio"  => "/nextcloud_data/data/larry/files/wobblehead-radio-episodes",
  "sub-therapy-radio" => "/nextcloud_data/data/calico/files/sub-therapy-radio-episodes",
  "necronome-radio"   => "/nextcloud_data/data/tim/files/necronome-radio-episodes",
  "all-day-junglist"   => "/nextcloud_data/data/mark/files/all-day-junglist-episodes"
}

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :tuesday, Tuesday.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :tuesday, Tuesday.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :tuesday, Tuesday.Endpoint, server: true
#
# You will also need to set the application root to `.` in order
# for the new static assets to be served after a hot upgrade:
#
#     config :tuesday, Tuesday.Endpoint, root: "."

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"
