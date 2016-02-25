defmodule Tuesday.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :pwhash, :string
      add :show_id, :integer

      timestamps
    end

  end
end
