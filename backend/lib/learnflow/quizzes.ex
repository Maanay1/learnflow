defmodule Learnflow.Quizzes do
  import Ecto.Query
  alias Ecto.Multi
  alias Learnflow.Quizzes.{Answer, Participant, Question, Quiz}
  alias Learnflow.Repo

  @code_chars ~c"ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

  def create_quiz(creator, attrs) do
    attrs = string_keys(attrs)
    questions = Map.get(attrs, "questions", [])

    if is_list(questions) and questions != [] do
      quiz_attrs =
        attrs
        |> Map.take(["title", "description", "time_limit_seconds", "question_time_seconds"])
        |> Map.put("creator_id", creator.id)
        |> Map.put("join_code", unique_join_code())

      Multi.new()
      |> Multi.insert(:quiz, Quiz.changeset(%Quiz{}, quiz_attrs))
      |> Multi.run(:questions, fn repo, %{quiz: quiz} ->
        insert_questions(repo, quiz.id, questions)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{quiz: quiz}} -> {:ok, get_quiz!(quiz.id)}
        {:error, _step, reason, _changes} -> {:error, reason}
      end
    else
      {:error, :questions_required}
    end
  end

  def list_created(user_id) do
    Quiz
    |> where([q], q.creator_id == ^user_id)
    |> order_by([q], desc: q.inserted_at)
    |> preload([:creator, :questions, participants: :user])
    |> Repo.all()
    |> Enum.map(&refresh_status/1)
  end

  def get_quiz_for_user(id, user_id) do
    case get_quiz(id) do
      nil ->
        {:error, :not_found}

      quiz ->
        participant = Enum.find(quiz.participants, &(&1.user_id == user_id))

        if quiz.creator_id == user_id or participant do
          {:ok, quiz, participant}
        else
          {:error, :not_joined}
        end
    end
  end

  def join_quiz(user, code) do
    code = code |> to_string() |> String.trim() |> String.upcase()
    quiz = Repo.get_by(Quiz, join_code: code) |> preload_quiz()

    cond do
      is_nil(quiz) ->
        {:error, :invalid_join_code}

      quiz.creator_id == user.id ->
        {:ok, quiz, nil}

      quiz.status != "waiting" ->
        {:error, :quiz_already_started}

      true ->
        now = utc_now()

        %Participant{}
        |> Participant.changeset(%{quiz_id: quiz.id, user_id: user.id, joined_at: now})
        |> Repo.insert(
          on_conflict: :nothing,
          conflict_target: [:quiz_id, :user_id],
          returning: true
        )
        |> case do
          {:ok, participant} ->
            participant =
              if participant.id,
                do: participant,
                else: Repo.get_by!(Participant, quiz_id: quiz.id, user_id: user.id)

            {:ok, get_quiz!(quiz.id), participant}

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  def start_quiz(user_id, id) do
    with {:ok, quiz} <- owned_quiz(user_id, id),
         "waiting" <- quiz.status do
      quiz
      |> Quiz.changeset(%{status: "active", started_at: utc_now()})
      |> Repo.update()
      |> with_preloads()
    else
      "active" -> {:error, :quiz_already_started}
      "finished" -> {:error, :quiz_finished}
      error -> error
    end
  end

  def finish_quiz(user_id, id) do
    with {:ok, quiz} <- owned_quiz(user_id, id) do
      quiz
      |> Quiz.changeset(%{status: "finished", finished_at: utc_now()})
      |> Repo.update()
      |> with_preloads()
    end
  end

  def submit_answers(user_id, id, answers) when is_list(answers) do
    with {:ok, quiz, participant} <- get_quiz_for_user(id, user_id),
         %Participant{} <- participant || {:error, :creator_cannot_submit},
         :ok <- can_submit?(quiz, participant),
         {:ok, normalized_answers} <- normalize_answers(quiz.questions, answers) do
      Multi.new()
      |> Multi.run(:answers, fn repo, _changes ->
        insert_answers(repo, participant, normalized_answers)
      end)
      |> Multi.update(
        :participant,
        Participant.changeset(participant, %{
          score: score(normalized_answers),
          submitted_at: utc_now()
        })
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{participant: updated}} -> {:ok, Repo.preload(updated, [:user, answers: :question])}
        {:error, _step, reason, _changes} -> {:error, reason}
      end
    else
      nil -> {:error, :not_joined}
      {:error, _reason} = error -> error
    end
  end

  def submit_answers(_user_id, _id, _answers), do: {:error, :invalid_answers}

  def results(user_id, id) do
    with {:ok, quiz, _participant} <- get_quiz_for_user(id, user_id),
         true <- quiz.creator_id == user_id or quiz.status == "finished" do
      {:ok, Enum.sort_by(quiz.participants, & &1.score, :desc)}
    else
      false -> {:error, :unauthorized}
      error -> error
    end
  end

  def time_remaining(%Quiz{
        status: "active",
        started_at: %DateTime{} = started_at,
        time_limit_seconds: limit
      }) do
    max(0, limit - DateTime.diff(utc_now(), started_at))
  end

  def time_remaining(%Quiz{status: "waiting", time_limit_seconds: limit}), do: limit
  def time_remaining(_quiz), do: 0

  defp insert_questions(repo, quiz_id, questions) do
    questions
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, []}, fn {attrs, position}, {:ok, inserted} ->
      attrs =
        attrs
        |> string_keys()
        |> Map.put("quiz_id", quiz_id)
        |> Map.put("position", position)

      case %Question{} |> Question.changeset(attrs) |> repo.insert() do
        {:ok, question} -> {:cont, {:ok, [question | inserted]}}
        {:error, changeset} -> {:halt, {:error, changeset}}
      end
    end)
  end

  defp normalize_answers(questions, answers) do
    questions_by_id = Map.new(questions, &{&1.id, &1})

    answers
    |> Enum.reduce_while({:ok, []}, fn attrs, {:ok, normalized} ->
      attrs = string_keys(attrs)
      question = Map.get(questions_by_id, Map.get(attrs, "question_id"))
      selected = to_integer(Map.get(attrs, "selected_option"))

      if question && selected in -1..3 do
        correct = selected == question.correct_option

        answer = %{
          question: question,
          selected_option: selected,
          correct: correct,
          points_awarded: if(correct, do: question.points, else: 0)
        }

        {:cont, {:ok, [answer | normalized]}}
      else
        {:halt, {:error, :invalid_answer}}
      end
    end)
    |> case do
      {:ok, normalized} ->
        unique_answers = Enum.uniq_by(normalized, & &1.question.id)

        if length(unique_answers) == length(questions),
          do: {:ok, unique_answers},
          else: {:error, :answer_every_question}

      error ->
        error
    end
  end

  defp insert_answers(repo, participant, answers) do
    answers
    |> Enum.reduce_while({:ok, []}, fn answer, {:ok, inserted} ->
      attrs =
        Map.merge(Map.drop(answer, [:question]), %{
          participant_id: participant.id,
          question_id: answer.question.id
        })

      case %Answer{} |> Answer.changeset(attrs) |> repo.insert() do
        {:ok, row} -> {:cont, {:ok, [row | inserted]}}
        {:error, changeset} -> {:halt, {:error, changeset}}
      end
    end)
  end

  defp can_submit?(%Quiz{status: "waiting"}, _participant), do: {:error, :quiz_not_started}
  defp can_submit?(%Quiz{status: "finished"}, _participant), do: {:error, :quiz_finished}

  defp can_submit?(_quiz, %Participant{submitted_at: %DateTime{}}),
    do: {:error, :already_submitted}

  defp can_submit?(quiz, _participant),
    do: if(time_remaining(quiz) > 0, do: :ok, else: {:error, :time_expired})

  defp score(answers), do: Enum.reduce(answers, 0, &(&1.points_awarded + &2))

  defp owned_quiz(user_id, id) do
    case Repo.get(Quiz, id) do
      %Quiz{creator_id: ^user_id} = quiz -> {:ok, quiz}
      %Quiz{} -> {:error, :unauthorized}
      nil -> {:error, :not_found}
    end
  end

  defp refresh_status(%Quiz{status: "active"} = quiz) do
    if time_remaining(quiz) == 0 do
      quiz |> Quiz.changeset(%{status: "finished", finished_at: utc_now()}) |> Repo.update!()
    else
      quiz
    end
  end

  defp refresh_status(quiz), do: quiz

  defp get_quiz(id), do: Repo.get(Quiz, id) |> preload_quiz() |> refresh_if_present()
  defp get_quiz!(id), do: Repo.get!(Quiz, id) |> preload_quiz() |> refresh_status()

  defp preload_quiz(nil), do: nil
  defp preload_quiz(quiz), do: Repo.preload(quiz, [:creator, :questions, participants: [:user, answers: :question]])

  defp refresh_if_present(nil), do: nil
  defp refresh_if_present(quiz), do: refresh_status(quiz)

  defp with_preloads({:ok, quiz}), do: {:ok, preload_quiz(quiz)}
  defp with_preloads(error), do: error

  defp unique_join_code do
    code = for _ <- 1..6, into: "", do: <<Enum.random(@code_chars)>>

    if Repo.exists?(from(q in Quiz, where: q.join_code == ^code)),
      do: unique_join_code(),
      else: code
  end

  defp to_integer(value) when is_integer(value), do: value

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> -1
    end
  end

  defp to_integer(_value), do: -1

  defp string_keys(map) when is_map(map),
    do: Map.new(map, fn {key, value} -> {to_string(key), value} end)

  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)
end
