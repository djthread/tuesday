defmodule Tuesday.Repo.Migrations.AddTableEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :happens_on, :date
      add :info_json, :text
      add :show_id, :integer
      add :user_id, :integer

      timestamps
    end
  end
end
