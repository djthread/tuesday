defmodule Tuesday.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :number, :integer
      add :title, :string
      add :record_date, :date
      add :filename, :string
      add :description, :binary

      add :user_id, references(:users)
      add :show_id, references(:shows)

      timestamps
    end

    create index(:episodes, [:show_id])
    create index(:episodes, [:number])
  end
end
