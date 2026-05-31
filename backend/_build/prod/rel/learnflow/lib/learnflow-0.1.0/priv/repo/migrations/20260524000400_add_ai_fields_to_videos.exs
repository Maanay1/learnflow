defmodule Learnflow.Repo.Migrations.AddAiFieldsToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :has_subtitles, :boolean, null: false, default: false
      add :subtitle_languages, {:array, :string}, null: false, default: []
      add :summary, :text
      add :ai_processed_at, :utc_datetime_usec
    end
  end
end
