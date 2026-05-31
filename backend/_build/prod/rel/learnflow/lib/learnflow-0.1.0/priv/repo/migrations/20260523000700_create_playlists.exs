defmodule Learnflow.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :title, :string, size: 200, null: false
      add :description, :text
      add :is_public, :boolean, null: false, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(:playlists, [:user_id])
  end
end
