defmodule Learnflow.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:creator_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false)
      add(:title, :string, size: 160, null: false)
      add(:description, :text)
      add(:join_code, :string, size: 6, null: false)
      add(:status, :string, size: 20, null: false, default: "waiting")
      add(:time_limit_seconds, :integer, null: false, default: 600)
      add(:started_at, :utc_datetime_usec)
      add(:finished_at, :utc_datetime_usec)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:quizzes, [:join_code]))
    create(index(:quizzes, [:creator_id]))

    create(
      constraint(:quizzes, :quizzes_status_check,
        check: "status IN ('waiting', 'active', 'finished')"
      )
    )

    create(
      constraint(:quizzes, :quizzes_time_limit_check,
        check: "time_limit_seconds BETWEEN 30 AND 7200"
      )
    )

    create table(:quiz_questions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:quiz_id, references(:quizzes, type: :binary_id, on_delete: :delete_all), null: false)
      add(:body, :text, null: false)
      add(:options, {:array, :string}, null: false)
      add(:correct_option, :integer, null: false)
      add(:points, :integer, null: false, default: 100)
      add(:position, :integer, null: false)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:quiz_questions, [:quiz_id, :position]))

    create(
      constraint(:quiz_questions, :quiz_questions_correct_option_check,
        check: "correct_option BETWEEN 0 AND 3"
      )
    )

    create(
      constraint(:quiz_questions, :quiz_questions_points_check,
        check: "points BETWEEN 1 AND 10000"
      )
    )

    create table(:quiz_participants, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:quiz_id, references(:quizzes, type: :binary_id, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false)
      add(:score, :integer, null: false, default: 0)
      add(:joined_at, :utc_datetime_usec, null: false)
      add(:submitted_at, :utc_datetime_usec)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:quiz_participants, [:quiz_id, :user_id]))

    create table(:quiz_answers, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(
        :participant_id,
        references(:quiz_participants, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:question_id, references(:quiz_questions, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:selected_option, :integer, null: false)
      add(:correct, :boolean, null: false, default: false)
      add(:points_awarded, :integer, null: false, default: 0)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:quiz_answers, [:participant_id, :question_id]))

    create(
      constraint(:quiz_answers, :quiz_answers_selected_option_check,
        check: "selected_option BETWEEN 0 AND 3"
      )
    )
  end
end
