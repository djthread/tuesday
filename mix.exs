defmodule Tuesday.Mixfile do
  use Mix.Project

  def project do
    {result, _exit_code} = System.cmd("git", ["rev-parse", "HEAD"])

    # truncate the commit SHA to 7 chars
    git_sha = String.slice(result, 0, 7)

    [ app: :tuesday,
      version: "0.0.1-#{git_sha}",
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [ mod: {Tuesday, []},
      applications: [ :phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                      :phoenix_ecto, :phoenix_pubsub, :postgrex, :httpoison,
                      :calecto, :sh, :fs, :cors_plug
                    ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [ {:phoenix,             "~> 1.3.0-rc"},
      {:phoenix_pubsub,      "~> 1.0"},
      {:phoenix_ecto,        "~> 3.2"},
      {:postgrex,            ">= 0.0.0"},
      {:scrivener_ecto,      "~> 1.0"},
      {:phoenix_html,        "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext,             "~> 0.11"},
      {:cowboy,              "~> 1.0"},
      {:httpoison,           "~> 0.11.0"},
      {:calecto,             "~> 0.16.0"},
      {:sh,                  "~> 1.1.2"},
      # {:hackney, "~> 1.6.0", [optional: false, hex: :hackney]},
      # {:floki,               "~> 0.0"},
      # {:exfswatch,           "~> 0.2.0"},
      # {:exrm,                "~> 1.0.0"},
      {:distillery,          "~> 0.9"},
      {:cors_plug,           "~> 1.1"},
      {:wallaby,             "~> 0.16.1"}
# <<<<<<< dfb6bd034e25e6b5f5f354d2e75c99d1461c1271
#       {:phoenix_pubsub,      "~> 1.0"},
#       {:phoenix_ecto,        "~> 3.0"},
#       {:postgrex,            ">= 0.0.0", [optional: true, hex: :postgrex]},
#       {:phoenix_html,        "~> 2.6.2"},
#       {:phoenix_live_reload, "~> 1.0", only: :dev},
#       {:gettext,             "~> 0.11"},
#       {:cowboy,              "~> 1.0"},
#       {:httpoison,           "~> 0.9.0"},
#       {:exrm,                "~> 1.0.0"}, # git: "http://github.com/bitwalker/exrm", tag: "1.0.0-rc7"},
#       {:calecto,             "~> 0.16.0"},
#       {:sh,                  "~> 1.1.2"},
#       # {:hackney, "~> 1.6.0", [optional: false, hex: :hackney]},
#       {:floki,               "~> 0.9.0"},
#       {:exfswatch,           "~> 0.2.0"}
# =======
#       {:phoenix_ecto,        "~> 3.0"},
#       {:postgrex,            ">= 0.0.0"},
#       {:phoenix_html,        "~> 2.6"},
#       {:phoenix_live_reload, "~> 1.0", only: :dev},
#       {:gettext,             "~> 0.11"},
#       {:cowboy,              "~> 1.0"},
#       {:httpoison,           "~> 0.8.0"},
#       {:exrm,                git: "http://github.com/bitwalker/exrm", tag: "1.0.8"},
#       {:calecto,             "~> 0.6.0"},
#       {:calendar,            "~> 0.14.0"},
#       {:sh,                  "~> 1.1.0"},
#       {:hackney, "~> 1.6.0", [optional: false, hex: :hackney]}
# >>>>>>> .
      # {:exrm, "~> 0.18.1"},
      # {:scrivener, "~> 1.1", override: true}
   ]

  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
