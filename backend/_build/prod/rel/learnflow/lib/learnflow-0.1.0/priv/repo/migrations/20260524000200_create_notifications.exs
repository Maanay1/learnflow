defmodule Learnflow.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email_notifications, :boolean, null: false, default: true
    end

    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :type, :string, size: 50, null: false
      add :actor_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :video_id, references(:videos, type: :binary_id, on_delete: :nilify_all)
      add :course_id, references(:playlists, type: :binary_id, on_delete: :nilify_all)
      add :comment_id, references(:comments, type: :binary_id, on_delete: :nilify_all)
      add :read_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:notifications, [:user_id, :read_at])
    create index(:notifications, [:user_id, :inserted_at])
    create constraint(:notifications, :notifications_type_check,
             check:
               "type IN ('new_follower', 'video_liked', 'video_commented', 'comment_replied', 'new_video_from_followed', 'course_completed')"
           )
  end
end
