defmodule Tuesday.Repo.Migrations.FixShowsUsersTable do
  use Ecto.Migration

  def change do
    drop table(:shows_users)

    create table(:shows_users, primary_key: false) do
      add :show_id, :integer
      add :user_id, :integer
    end
  end
end
