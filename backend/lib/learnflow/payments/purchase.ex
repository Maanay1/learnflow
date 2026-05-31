defmodule Learnflow.Payments.Purchase do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "purchases" do
    belongs_to :user, Learnflow.Accounts.User
    belongs_to :course, Learnflow.Dashboard.Playlist
    field :stripe_payment_intent_id, :string
    field :amount_cents, :integer
    field :creator_payout_cents, :integer
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(purchase, attrs) do
    purchase
    |> cast(attrs, [:user_id, :course_id, :stripe_payment_intent_id, :amount_cents, :creator_payout_cents, :status])
    |> validate_required([:user_id, :course_id, :stripe_payment_intent_id, :amount_cents, :creator_payout_cents, :status])
    |> validate_inclusion(:status, ["pending", "completed", "refunded"])
    |> validate_number(:amount_cents, greater_than_or_equal_to: 0)
    |> validate_number(:creator_payout_cents, greater_than_or_equal_to: 0)
    |> unique_constraint(:stripe_payment_intent_id)
    |> unique_constraint([:user_id, :course_id])
  end
end
