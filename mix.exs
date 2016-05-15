defmodule Tuesday.Mixfile do
  use Mix.Project

  def project do
    {result, _exit_code} = System.cmd("git", ["rev-parse", "HEAD"])

    # We'll truncate the commit SHA to 7 chars. Feel free to change
    git_sha = String.slice(result, 0, 7)

    [app: :tuesday,
     version: "0.0.1-#{git_sha}",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Tuesday, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :httpoison, :calendar, :calecto]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [ {:phoenix,             "~> 1.1.4"},
      {:phoenix_ecto,        "~> 3.0-beta"},
      {:postgrex,            "~> 0.11.0", [optional: true, hex: :postgrex]},
      {:phoenix_html,        "~> 2.5", [optional: true, hex: :phoenix_html]},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext,             "~> 0.9"},
      {:cowboy,              "~> 1.0"},
      {:httpoison,           "~> 0.8.0"},
      {:exrm,                git: "http://github.com/bitwalker/exrm", tag: "1.0.0-rc7"},
      {:calecto,             "~> 0.6.0"},
      {:calendar,            "~> 0.14.0"},
      {:sh,                  "~> 1.1.0"},
      {:hackney, "~> 1.6.0", [optional: false, hex: :hackney]}
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
