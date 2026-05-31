defmodule Learnflow.Workers.AutoChaptersJob do
  use Oban.Worker, queue: :ai, max_attempts: 3

  alias Learnflow.AI

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"video_id" => video_id}}) do
    case AI.auto_generate_chapters(video_id) do
      {:ok, _chapters} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
