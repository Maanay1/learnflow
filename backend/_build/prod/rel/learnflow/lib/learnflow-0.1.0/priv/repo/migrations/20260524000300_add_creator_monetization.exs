defmodule Learnflow.Repo.Migrations.AddCreatorMonetization do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists :stripe_account_id, :string, size: 100
      add_if_not_exists :stripe_onboarding_complete, :boolean, null: false, default: false
      add_if_not_exists :payout_email, :string, size: 255
    end

    alter table(:playlists) do
      add_if_not_exists :is_paid, :boolean, null: false, default: false
      add_if_not_exists :price_cents, :integer, null: false, default: 0
    end

    create table(:purchases, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :course_id, references(:playlists, type: :binary_id, on_delete: :delete_all), null: false
      add :stripe_payment_intent_id, :string, size: 100, null: false
      add :amount_cents, :integer, null: false
      add :creator_payout_cents, :integer, null: false
      add :status, :string, size: 20, null: false, default: "pending"

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:purchases, [:stripe_payment_intent_id])
    create unique_index(:purchases, [:user_id, :course_id], where: "status IN ('pending', 'completed')")
    create index(:purchases, [:user_id])
    create index(:purchases, [:course_id])
    create constraint(:purchases, :purchases_status_check, check: "status IN ('pending', 'completed', 'refunded')")
    create constraint(:purchases, :purchases_amount_check, check: "amount_cents >= 0 AND creator_payout_cents >= 0")
  end
end
