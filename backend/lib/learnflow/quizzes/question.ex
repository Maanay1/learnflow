defmodule Learnflow.Quizzes.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quiz_questions" do
    belongs_to(:quiz, Learnflow.Quizzes.Quiz)
    field(:body, :string)
    field(:options, {:array, :string}, default: [])
    field(:correct_option, :integer)
    field(:points, :integer, default: 100)
    field(:position, :integer)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:quiz_id, :body, :options, :correct_option, :points, :position])
    |> validate_required([:quiz_id, :body, :options, :correct_option, :points, :position])
    |> validate_length(:body, min: 2, max: 500)
    |> validate_length(:options, is: 4)
    |> validate_change(:options, fn :options, options ->
      if Enum.all?(options, &(is_binary(&1) and String.trim(&1) != "")),
        do: [],
        else: [options: "must contain four non-empty options"]
    end)
    |> validate_number(:correct_option, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> validate_number(:points, greater_than: 0, less_than_or_equal_to: 10_000)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> unique_constraint([:quiz_id, :position])
  end
end
