defmodule Tuesday.Repo.Migrations.CreateShow do
  use Ecto.Migration

  def change do
    create table(:shows) do
      add :name, :string

      timestamps
    end

  end
end
