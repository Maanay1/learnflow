defmodule Learnflow.Workers.GenerateSummaryJob do
  use Oban.Worker, queue: :ai, max_attempts: 3

  alias Learnflow.AI

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"video_id" => video_id}}) do
    case AI.generate_summary(video_id) do
      {:ok, _summary} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
