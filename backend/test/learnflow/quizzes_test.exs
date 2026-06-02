defmodule Learnflow.QuizzesTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Quizzes

  defp user(prefix) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Accounts.register_user(%{
        "username" => "#{prefix}_#{n}",
        "email" => "#{prefix}_#{n}@example.com",
        "password" => "learn1234"
      })

    user
  end

  defp questions do
    [
      %{
        "body" => "Сколько будет 2 + 2?",
        "options" => ["3", "4", "5", "6"],
        "correct_option" => 1,
        "points" => 150
      }
    ]
  end

  test "creator starts a quiz and participant submits scored answers" do
    creator = user("quiz_creator")
    learner = user("quiz_learner")

    assert {:ok, quiz} =
             Quizzes.create_quiz(creator, %{
               "title" => "Быстрая математика",
               "time_limit_seconds" => 300,
               "questions" => questions()
             })

    assert quiz.status == "waiting"
    assert String.length(quiz.join_code) == 6

    assert {:ok, joined_quiz, participant} = Quizzes.join_quiz(learner, quiz.join_code)
    assert joined_quiz.id == quiz.id
    assert participant.user_id == learner.id

    assert {:error, :unauthorized} = Quizzes.start_quiz(learner.id, quiz.id)
    assert {:ok, active_quiz} = Quizzes.start_quiz(creator.id, quiz.id)
    assert active_quiz.status == "active"

    question = hd(active_quiz.questions)

    assert {:ok, scored} =
             Quizzes.submit_answers(learner.id, quiz.id, [
               %{"question_id" => question.id, "selected_option" => 1}
             ])

    assert scored.score == 150

    assert {:error, :already_submitted} =
             Quizzes.submit_answers(learner.id, quiz.id, [
               %{"question_id" => question.id, "selected_option" => 1}
             ])

    assert {:ok, finished_quiz} = Quizzes.finish_quiz(creator.id, quiz.id)
    assert finished_quiz.status == "finished"
    assert {:ok, [result]} = Quizzes.results(learner.id, quiz.id)
    assert result.score == 150
  end
end
