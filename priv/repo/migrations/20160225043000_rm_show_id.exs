defmodule Tuesday.Repo.Migrations.RmShowId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :show_id
    end
  end
end
