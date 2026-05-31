defmodule Learnflow.Repo.Migrations.CreateVideoChapters do
  use Ecto.Migration

  def change do
    create table(:video_chapters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), null: false
      add :title, :string, size: 200, null: false
      add :start_seconds, :integer, null: false
      add :position, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:video_chapters, [:video_id])
  end
end
