defmodule Learnflow.Repo.Migrations.CreateCertificates do
  use Ecto.Migration

  def change do
    create table(:certificates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :playlist_id, references(:playlists, type: :binary_id, on_delete: :delete_all), null: false
      add :certificate_number, :string, size: 50, null: false
      add :issued_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:certificates, [:certificate_number])
    create index(:certificates, [:user_id])
    create index(:certificates, [:playlist_id])
  end
end
