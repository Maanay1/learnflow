defmodule Learnflow.Repo.Migrations.CreateMessaging do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false, default: "direct"
      add :name, :string, size: 100
      add :avatar_key, :string
      add :description, :text
      add :creator_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :max_members, :integer, null: false, default: 200

      timestamps(type: :utc_datetime_usec)
    end

    create table(:conversation_members, primary_key: false) do
      add :conversation_id, references(:conversations, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :role, :string, null: false, default: "member"
      add :joined_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :last_read_at, :utc_datetime_usec
    end

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :conversation_id, references(:conversations, type: :binary_id, on_delete: :delete_all), null: false
      add :sender_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :body, :text
      add :message_type, :string, null: false, default: "text"
      add :shared_video_id, references(:videos, type: :binary_id, on_delete: :nilify_all)
      add :read_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:conversations, [:creator_id])
    create index(:conversations, [:type])
    create index(:conversation_members, [:user_id])
    create index(:messages, [:conversation_id, :inserted_at, :id])
    create index(:messages, [:sender_id])
    create index(:messages, [:shared_video_id])

    create constraint(:conversations, :conversation_type_check, check: "type in ('direct', 'group')")
    create constraint(:conversation_members, :conversation_member_role_check, check: "role in ('admin', 'member')")
    create constraint(:messages, :message_type_check, check: "message_type in ('text', 'image', 'video_share')")
  end
end
