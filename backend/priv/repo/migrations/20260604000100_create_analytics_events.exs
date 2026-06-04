defmodule Learnflow.Repo.Migrations.CreateAnalyticsEvents do
  use Ecto.Migration

  def change do
    create table(:analytics_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_type, :string, null: false
      add :actor_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :target_user_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :metadata, :map, null: false, default: %{}
      add :ip_address, :string
      add :user_agent, :text

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:analytics_events, [:event_type])
    create index(:analytics_events, [:actor_id])
    create index(:analytics_events, [:target_user_id])
    create index(:analytics_events, [:inserted_at])
  end
end
