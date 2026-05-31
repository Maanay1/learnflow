defmodule Learnflow.Repo.Migrations.CreateWatchProgress do
  use Ecto.Migration

  def change do
    create table(:watch_progress, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :seconds_watched, :integer, null: false, default: 0
      add :completed, :boolean, null: false, default: false
      add :last_watched_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end
  end
end
