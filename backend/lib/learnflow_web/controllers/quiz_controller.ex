defmodule LearnflowWeb.QuizController do
  use LearnflowWeb, :controller
  alias Learnflow.Accounts
  alias Learnflow.Quizzes
  alias Learnflow.Storage

  @quiz_image_types %{
    "image/jpeg" => ".jpg",
    "image/png" => ".png",
    "image/webp" => ".webp"
  }
  @max_quiz_image_bytes 8 * 1024 * 1024

  def index(conn, _params) do
    quizzes = Quizzes.list_created(conn.assigns.current_user.id)
    json(conn, %{quizzes: Enum.map(quizzes, &quiz_json(&1, conn.assigns.current_user.id))})
  end

  def create(conn, params) do
    with {:ok, quiz} <- Quizzes.create_quiz(conn.assigns.current_user, params) do
      conn
      |> put_status(:created)
      |> json(%{quiz: quiz_json(quiz, conn.assigns.current_user.id)})
    end
  end

  def image(conn, %{"image" => %Plug.Upload{} = upload}) do
    with {:ok, extension} <- image_extension(upload.content_type),
         {:ok, %{size: size}} when size <= @max_quiz_image_bytes <- File.stat(upload.path),
         {:ok, body} <- File.read(upload.path),
         key = "quiz-images/#{conn.assigns.current_user.id}/#{Ecto.UUID.generate()}#{extension}",
         {:ok, _response} <- Storage.put_object(Storage.bucket_thumbnails(), key, body, upload.content_type) do
      token = Base.url_encode64(key, padding: false)
      json(conn, %{image_url: "/api/quizzes/images/#{token}"})
    else
      {:ok, %{size: _}} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "image_too_large"})
      {:error, :invalid_image_type} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_image_type"})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
    end
  end

  def image(conn, _params), do: conn |> put_status(:unprocessable_entity) |> json(%{error: "image_required"})

  def image_file(conn, %{"token" => token}) do
    with {:ok, key} <- Base.url_decode64(token, padding: false),
         true <- String.starts_with?(key, "quiz-images/"),
         {:ok, body} <- Storage.get_object(Storage.bucket_thumbnails(), key) do
      conn
      |> put_resp_content_type(image_content_type(key))
      |> put_resp_header("cache-control", "public, max-age=86400")
      |> send_resp(:ok, body)
    else
      _ -> {:error, :not_found}
    end
  end

  def join(conn, %{"code" => code}) do
    with {:ok, quiz, participant} <- Quizzes.join_quiz(conn.assigns.current_user, code) do
      json(conn, %{quiz: quiz_json(quiz, conn.assigns.current_user.id, participant)})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, quiz, participant} <- Quizzes.get_quiz_for_user(id, conn.assigns.current_user.id) do
      json(conn, %{quiz: quiz_json(quiz, conn.assigns.current_user.id, participant)})
    end
  end

  def start(conn, %{"id" => id}) do
    with {:ok, quiz} <- Quizzes.start_quiz(conn.assigns.current_user.id, id) do
      json(conn, %{quiz: quiz_json(quiz, conn.assigns.current_user.id)})
    end
  end

  def finish(conn, %{"id" => id}) do
    with {:ok, quiz} <- Quizzes.finish_quiz(conn.assigns.current_user.id, id) do
      json(conn, %{quiz: quiz_json(quiz, conn.assigns.current_user.id)})
    end
  end

  def submit(conn, %{"id" => id, "answers" => answers}) do
    with {:ok, participant} <- Quizzes.submit_answers(conn.assigns.current_user.id, id, answers) do
      json(conn, %{participant: participant_json(participant)})
    end
  end

  def results(conn, %{"id" => id}) do
    with {:ok, participants} <- Quizzes.results(conn.assigns.current_user.id, id) do
      json(conn, %{participants: Enum.map(participants, &participant_json/1)})
    end
  end

  defp quiz_json(quiz, viewer_id, participant \\ nil) do
    owner = quiz.creator_id == viewer_id
    show_questions = owner or quiz.status in ["active", "finished"]

    %{
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      status: quiz.status,
      time_limit_seconds: quiz.time_limit_seconds,
      question_time_seconds: quiz.question_time_seconds,
      time_remaining_seconds: Quizzes.time_remaining(quiz),
      started_at: quiz.started_at,
      finished_at: quiz.finished_at,
      join_code: if(owner, do: quiz.join_code),
      is_owner: owner,
      creator: Accounts.public_user(quiz.creator),
      participant: participant && participant_json(participant),
      participants_count: length(quiz.participants),
      questions:
        if(show_questions,
          do:
            quiz.questions
            |> Enum.sort_by(& &1.position)
            |> Enum.map(&question_json(&1, owner or quiz.status == "finished")),
          else: []
        )
    }
  end

  defp question_json(question, reveal_answer) do
    %{
      id: question.id,
      body: question.body,
      image_url: question.image_url,
      options: question.options,
      points: question.points,
      position: question.position,
      correct_option: if(reveal_answer, do: question.correct_option)
    }
  end

  defp participant_json(participant) do
    %{
      id: participant.id,
      score: participant.score,
      joined_at: participant.joined_at,
      submitted_at: participant.submitted_at,
      user: participant |> Map.get(:user) |> loaded_user() |> Accounts.public_user(),
      answers:
        participant
        |> Map.get(:answers)
        |> loaded_many()
        |> Enum.sort_by(&(&1.question && &1.question.position || 0))
        |> Enum.map(&answer_json/1)
    }
  end

  defp answer_json(answer) do
    %{
      id: answer.id,
      question_id: answer.question_id,
      selected_option: answer.selected_option,
      correct: answer.correct,
      points_awarded: answer.points_awarded,
      question:
        answer
        |> Map.get(:question)
        |> loaded_question()
        |> then(fn question -> question && question_json(question, true) end)
    }
  end

  defp loaded_user(%Ecto.Association.NotLoaded{}), do: nil
  defp loaded_user(user), do: user
  defp loaded_question(%Ecto.Association.NotLoaded{}), do: nil
  defp loaded_question(question), do: question
  defp loaded_many(%Ecto.Association.NotLoaded{}), do: []
  defp loaded_many(nil), do: []
  defp loaded_many(values), do: values

  defp image_extension(content_type) do
    case Map.fetch(@quiz_image_types, content_type) do
      {:ok, extension} -> {:ok, extension}
      :error -> {:error, :invalid_image_type}
    end
  end

  defp image_content_type(key) do
    cond do
      String.ends_with?(key, ".png") -> "image/png"
      String.ends_with?(key, ".webp") -> "image/webp"
      true -> "image/jpeg"
    end
  end
end
