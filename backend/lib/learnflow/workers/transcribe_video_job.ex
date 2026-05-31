defmodule Learnflow.Workers.TranscribeVideoJob do
  use Oban.Worker, queue: :ai, max_attempts: 3

  alias Learnflow.AI
  alias Learnflow.Repo
  alias Learnflow.Videos.Video
  alias Learnflow.Workers.{AutoChaptersJob, GenerateSummaryJob}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"video_id" => video_id}}) do
    case Repo.get(Video, video_id) do
      %Video{video_key: key} = video when is_binary(key) ->
        with {:ok, _vtt} <- AI.transcribe_video(key, video.language) do
          %{video_id: video.id} |> GenerateSummaryJob.new(schedule_in: 5) |> Oban.insert()
          %{video_id: video.id} |> AutoChaptersJob.new(schedule_in: 10) |> Oban.insert()
          :ok
        end

      _ ->
        {:cancel, :video_not_ready}
    end
  end
end
