defmodule Tuesday.Repo.Migrations.AddShowId3Fields do
  use Ecto.Migration

  def change do
    alter table(:shows) do
      add :genre, :string
      add :podcast_name, :string
    end
  end
end
