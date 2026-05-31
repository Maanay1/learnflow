defmodule Learnflow.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows, primary_key: false) do
      add :follower_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :following_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true

      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:follows, :follows_no_self_follow_check, check: "follower_id <> following_id")
    create index(:follows, [:follower_id])
    create index(:follows, [:following_id])
  end
end
