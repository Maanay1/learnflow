defmodule Learnflow.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :video_id, references(:videos, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :parent_id, references(:comments, type: :binary_id, on_delete: :nilify_all)
      add :body, :text, null: false
      add :is_deleted, :boolean, null: false, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:comments, [:video_id])
    create index(:comments, [:user_id])
    create index(:comments, [:parent_id])

    execute("""
    CREATE FUNCTION comments_max_two_levels() RETURNS trigger AS $$
    DECLARE
      parent_parent_id uuid;
    BEGIN
      IF NEW.parent_id IS NULL THEN
        RETURN NEW;
      END IF;

      SELECT parent_id INTO parent_parent_id FROM comments WHERE id = NEW.parent_id;

      IF parent_parent_id IS NOT NULL THEN
        RAISE EXCEPTION 'comments cannot be nested deeper than 2 levels';
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
    """)

    execute("""
    CREATE TRIGGER comments_max_two_levels_trigger
    BEFORE INSERT OR UPDATE OF parent_id ON comments
    FOR EACH ROW EXECUTE FUNCTION comments_max_two_levels()
    """)
  end
end
