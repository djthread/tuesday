defmodule Tuesday.Repo.Migrations.AddEventDesc do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :description, :text
    end
  end
end
