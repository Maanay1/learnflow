defmodule Learnflow.Quizzes.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quiz_participants" do
    belongs_to(:quiz, Learnflow.Quizzes.Quiz)
    belongs_to(:user, Learnflow.Accounts.User)
    has_many(:answers, Learnflow.Quizzes.Answer)
    field(:score, :integer, default: 0)
    field(:joined_at, :utc_datetime_usec)
    field(:submitted_at, :utc_datetime_usec)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:quiz_id, :user_id, :score, :joined_at, :submitted_at])
    |> validate_required([:quiz_id, :user_id, :score, :joined_at])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> unique_constraint([:quiz_id, :user_id])
  end
end
