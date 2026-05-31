defmodule Learnflow.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto", "DROP EXTENSION IF EXISTS pgcrypto")

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, size: 30, null: false
      add :email, :string, size: 255, null: false
      add :password_hash, :string, null: false
      add :display_name, :string, size: 100
      add :avatar_key, :string
      add :bio, :text
      add :is_creator, :boolean, null: false, default: false
      add :is_verified, :boolean, null: false, default: false
      add :failed_login_attempts, :integer, null: false, default: 0
      add :locked_until, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
