defmodule Learnflow.Repo.Migrations.CreateVideoTags do
  use Ecto.Migration

  def change do
    create table(:video_tags, primary_key: false) do
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :tag_id, references(:subject_tags, type: :binary_id, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
