defmodule Learnflow.Quizzes.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quiz_answers" do
    belongs_to(:participant, Learnflow.Quizzes.Participant)
    belongs_to(:question, Learnflow.Quizzes.Question)
    field(:selected_option, :integer)
    field(:correct, :boolean, default: false)
    field(:points_awarded, :integer, default: 0)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:participant_id, :question_id, :selected_option, :correct, :points_awarded])
    |> validate_required([
      :participant_id,
      :question_id,
      :selected_option,
      :correct,
      :points_awarded
    ])
    |> validate_number(:selected_option, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> validate_number(:points_awarded, greater_than_or_equal_to: 0)
    |> unique_constraint([:participant_id, :question_id])
  end
end
