defmodule Learnflow.Repo.Migrations.CreatePlaylistVideos do
  use Ecto.Migration

  def change do
    create table(:playlist_videos, primary_key: false) do
      add :playlist_id, references(:playlists, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :position, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
