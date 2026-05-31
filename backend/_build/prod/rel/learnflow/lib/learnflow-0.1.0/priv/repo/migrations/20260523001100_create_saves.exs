defmodule Learnflow.Repo.Migrations.CreateSaves do
  use Ecto.Migration

  def change do
    create table(:saves, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
