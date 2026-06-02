defmodule Learnflow.Repo.Migrations.AddFormatToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:format, :string, size: 20, null: false, default: "media")
    end

    create(index(:videos, [:format, :status]))

    create(constraint(:videos, :videos_format_check, check: "format IN ('media', 'jq')"))
  end
end
