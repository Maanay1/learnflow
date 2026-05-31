defmodule Learnflow.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :ip_address, :string
      add :user_agent, :text
      add :expires_at, :utc_datetime_usec, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:sessions, [:token_hash])
    create index(:sessions, [:user_id])
    create index(:sessions, [:expires_at])
  end
end
