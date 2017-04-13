defmodule Tuesday.Repo.Migrations.AddChatEntries do
  use Ecto.Migration

  def change do
    create table(:chat_entries) do
      add :msg, :string
      add :nick, :string
      add :body, :string

      timestamps()
    end
  end

end
