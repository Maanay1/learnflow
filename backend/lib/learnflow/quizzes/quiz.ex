defmodule Learnflow.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizzes" do
    belongs_to(:creator, Learnflow.Accounts.User)
    has_many(:questions, Learnflow.Quizzes.Question)
    has_many(:participants, Learnflow.Quizzes.Participant)
    field(:title, :string)
    field(:description, :string)
    field(:join_code, :string)
    field(:status, :string, default: "waiting")
    field(:time_limit_seconds, :integer, default: 600)
    field(:question_time_seconds, :integer, default: 30)
    field(:started_at, :utc_datetime_usec)
    field(:finished_at, :utc_datetime_usec)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [
      :creator_id,
      :title,
      :description,
      :join_code,
      :status,
      :time_limit_seconds,
      :question_time_seconds,
      :started_at,
      :finished_at
    ])
    |> validate_required([:creator_id, :title, :join_code, :status, :time_limit_seconds])
    |> validate_length(:title, min: 3, max: 160)
    |> validate_length(:join_code, is: 6)
    |> validate_format(:join_code, ~r/^[A-Z0-9]+$/)
    |> validate_inclusion(:status, ~w(waiting active finished))
    |> validate_number(:time_limit_seconds,
      greater_than_or_equal_to: 30,
      less_than_or_equal_to: 7200
    )
    |> validate_number(:question_time_seconds,
      greater_than_or_equal_to: 10,
      less_than_or_equal_to: 300
    )
    |> unique_constraint(:join_code)
  end
end
