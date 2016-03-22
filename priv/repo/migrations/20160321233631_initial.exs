defmodule Tuesday.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :pwhash, :string
      add :is_admin, :boolean

      timestamps
    end

    create index(:users, [:name], unique: true)

    create table(:shows) do
      add :name, :string
      add :slug, :string

      timestamps
    end

    create table(:episodes) do
      add :number, :integer
      add :title, :string
      add :record_date, :date
      add :filename, :string
      add :description, :text

      add :user_id, references(:users)
      add :show_id, references(:shows)

      timestamps
    end

    create index(:episodes, [:show_id])
    create index(:episodes, [:number])

    create table(:shows_users, primary_key: false) do
      add :show_id, :integer
      add :user_id, :integer
    end
  end
end
