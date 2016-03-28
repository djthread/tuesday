defmodule Tuesday.Repo.Migrations.AddShowInfos do
  use Ecto.Migration

  def change do
    alter table(:shows) do
      add :hosted_by, :string
      add :recurring_note, :string
      add :tiny_info, :string
      add :short_info, :text
      add :full_info, :text
    end
  end
end
