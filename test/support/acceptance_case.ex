defmodule Tuesday.AcceptanceCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Tuesday.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Tuesday.Web.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tuesday.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Tuesday.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Tuesday.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
