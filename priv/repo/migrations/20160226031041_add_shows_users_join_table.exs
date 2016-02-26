defmodule Tuesday.Repo.Migrations.AddShowsUsersJoinTable do
  use Ecto.Migration

  def change do
    create table(:shows_users) do
      add :show_id, :integer
      add :user_id, :integer
    end
  end
end
