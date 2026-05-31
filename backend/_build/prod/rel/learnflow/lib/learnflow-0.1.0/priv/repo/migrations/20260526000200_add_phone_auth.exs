defmodule Learnflow.Repo.Migrations.AddPhoneAuth do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :email, :string, size: 255, null: true
      add :phone, :string, size: 20
      add :phone_verified, :boolean, null: false, default: false
    end

    create unique_index(:users, [:phone], where: "phone is not null")

    create table(:phone_verifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phone, :string, size: 20, null: false
      add :code, :string, size: 128, null: false
      add :attempts, :integer, null: false, default: 0
      add :expires_at, :utc_datetime_usec, null: false
      add :used, :boolean, null: false, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:phone_verifications, [:phone, :used, :expires_at])
  end
end
