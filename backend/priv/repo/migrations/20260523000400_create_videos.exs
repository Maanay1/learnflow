defmodule Learnflow.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :creator_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :title, :string, size: 200, null: false
      add :description, :text
      add :slug, :string, size: 200, null: false
      add :status, :string, size: 20, null: false, default: "pending"
      add :difficulty, :string, size: 20
      add :language, :string, size: 10, null: false, default: "ru"
      add :duration_seconds, :integer
      add :thumbnail_key, :string
      add :video_key, :string
      add :view_count, :integer, null: false, default: 0
      add :search_vector, :tsvector

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:videos, [:slug])
    create index(:videos, [:creator_id])
    create index(:videos, [:status])
    create index(:videos, [:language])
    create index(:videos, [:search_vector], using: "GIN")

    create constraint(:videos, :videos_status_check,
             check: "status IN ('pending', 'active', 'rejected', 'deleted')"
           )

    create constraint(:videos, :videos_difficulty_check,
             check: "difficulty IS NULL OR difficulty IN ('beginner', 'intermediate', 'advanced')"
           )

    execute("""
    CREATE FUNCTION videos_search_vector_refresh() RETURNS trigger AS $$
    BEGIN
      UPDATE videos
      SET search_vector =
        setweight(to_tsvector('simple', coalesce(NEW.title, '')), 'A') ||
        setweight(to_tsvector('simple', coalesce(NEW.description, '')), 'B')
      WHERE id = NEW.id;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
    """)

    execute("""
    CREATE TRIGGER videos_search_vector_trigger
    AFTER INSERT OR UPDATE OF title, description ON videos
    FOR EACH ROW EXECUTE FUNCTION videos_search_vector_refresh()
    """)
  end
end
