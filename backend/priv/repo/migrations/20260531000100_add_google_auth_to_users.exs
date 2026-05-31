defmodule Learnflow.Repo.Migrations.AddGoogleAuthToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :google_id, :string
      add :avatar_url, :text
    end

    create unique_index(:users, [:google_id], where: "google_id is not null")
  end
end
