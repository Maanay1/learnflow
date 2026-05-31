defmodule Learnflow.Repo.Migrations.AddCourseFieldsToPlaylists do
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      add :slug, :string, size: 220
      add :subject_tag_id, references(:subject_tags, type: :binary_id, on_delete: :nilify_all)
      add :difficulty, :string, size: 20
      add :status, :string, size: 20, null: false, default: "draft"
      add :is_paid, :boolean, null: false, default: false
      add :price_cents, :integer, null: false, default: 0
      add :thumbnail_key, :string
    end

    execute """
    UPDATE playlists
    SET slug = lower(regexp_replace(title, '[^a-zA-Z0-9]+', '-', 'g')) || '-' || substr(id::text, 1, 8)
    WHERE slug IS NULL
    """

    create unique_index(:playlists, [:slug])
    create index(:playlists, [:status])
    create index(:playlists, [:subject_tag_id])
    create index(:playlists, [:difficulty])
    create constraint(:playlists, :playlists_status_check, check: "status IN ('draft', 'published', 'archived')")
    create constraint(:playlists, :playlists_difficulty_check, check: "difficulty IS NULL OR difficulty IN ('beginner', 'intermediate', 'advanced')")
    create constraint(:playlists, :playlists_price_check, check: "price_cents >= 0")
  end
end
