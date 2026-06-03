defmodule Learnflow.Repo.Migrations.AddQuizQuestionTimingAndMedia do
  use Ecto.Migration

  def change do
    alter table(:quizzes) do
      add(:question_time_seconds, :integer, null: false, default: 30)
    end

    create(
      constraint(:quizzes, :quizzes_question_time_seconds_check,
        check: "question_time_seconds BETWEEN 10 AND 300"
      )
    )

    alter table(:quiz_questions) do
      add(:image_url, :text)
    end

    drop(constraint(:quiz_answers, :quiz_answers_selected_option_check))

    create(
      constraint(:quiz_answers, :quiz_answers_selected_option_check,
        check: "selected_option BETWEEN -1 AND 3"
      )
    )
  end
end
