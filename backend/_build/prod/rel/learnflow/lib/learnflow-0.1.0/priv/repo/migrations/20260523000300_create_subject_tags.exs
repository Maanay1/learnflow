defmodule Learnflow.Repo.Migrations.CreateSubjectTags do
  use Ecto.Migration

  def change do
    create table(:subject_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, size: 50, null: false
      add :slug, :string, size: 50, null: false
      add :color, :string, size: 7, null: false, default: "#6366f1"

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:subject_tags, [:name])
    create unique_index(:subject_tags, [:slug])

    execute("""
    INSERT INTO subject_tags (id, name, slug, color, inserted_at, updated_at) VALUES
      (gen_random_uuid(), 'Mathematics', 'mathematics', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Physics', 'physics', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Chemistry', 'chemistry', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Biology', 'biology', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Programming', 'programming', '#6366f1', now(), now()),
      (gen_random_uuid(), 'History', 'history', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Languages', 'languages', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Economics', 'economics', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Design', 'design', '#6366f1', now(), now()),
      (gen_random_uuid(), 'Philosophy', 'philosophy', '#6366f1', now(), now())
    """)
  end
end
