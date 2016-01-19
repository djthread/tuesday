ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Tuesday.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Tuesday.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Tuesday.Repo)

