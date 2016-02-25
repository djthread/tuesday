defmodule Tuesday.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :number, :integer
      add :title, :string
      add :record_date, :date
      add :filename, :string
      add :description, :string

      timestamps
    end

  end
end
