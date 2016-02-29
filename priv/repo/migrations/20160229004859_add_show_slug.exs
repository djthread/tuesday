defmodule Tuesday.Repo.Migrations.AddShowSlug do
  use Ecto.Migration

  def change do
    alter table(:shows) do
      add :slug, :string
    end

    alter table(:episodes) do
      modify :description, :text
    end
  end
end
