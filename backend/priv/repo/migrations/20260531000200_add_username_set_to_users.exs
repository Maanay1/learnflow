defmodule Learnflow.Repo.Migrations.AddUsernameSetToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username_set, :boolean, null: false, default: true
    end
  end
end
