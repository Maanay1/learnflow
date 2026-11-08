defmodule Learnflow.Workers.ProcessVideoJob do
  @moduledoc """
  Runs after an upload is confirmed:

    * reads the real duration with ffprobe;
    * converts formats that do not play everywhere (iPhone MOV/HEVC, WebM,
      MKV, very large resolutions) into MP4 H.264/AAC;
    * extracts a preview frame when the creator did not upload a thumbnail.

  Uploads that are not web-ready stay `pending` until this job publishes them.
  """
  use Oban.Worker, queue: :media, max_attempts: 3

  require Logger

  alias Learnflow.{Media, Storage, Videos}
  alias Learnflow.Videos.Video

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"video_id" => video_id}} = job) do
    case Videos.get_video_by_id(video_id) do
      %Video{video_key: key} = video when is_binary(key) and key != "" ->
        if String.starts_with?(key, "http") do
          :ok
        else
          process(video, job)
        end

      _ ->
        {:cancel, :video_not_ready}
    end
  end

  # Large videos on a small instance can take a while.
  @impl Oban.Worker
  def timeout(_job), do: :timer.hours(2)

  defp process(%Video{} = video, job) do
    dir = Path.join(System.tmp_dir!(), "jarq-video-#{video.id}-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    source = Path.join(dir, "source" <> Path.extname(video.video_key))

    result =
      with :ok <- ensure_ffmpeg(),
           :ok <- Storage.download_file(Storage.bucket_videos(), video.video_key, source),
           {:ok, info} <- Media.probe(source),
           {:ok, video_attrs} <- maybe_transcode(video, info, source, dir),
           {:ok, thumb_attrs} <- maybe_thumbnail(video, info, source, dir) do
        attrs =
          video_attrs
          |> Map.merge(thumb_attrs)
          |> Map.merge(duration_attrs(video, info))

        Videos.finish_processing(video, attrs)
      end

    File.rm_rf(dir)
    handle_result(result, video, job)
  end

  defp handle_result({:ok, _video}, _video_before, _job), do: :ok

  defp handle_result({:error, reason}, video, %Oban.Job{attempt: attempt, max_attempts: max}) do
    Logger.warning("Video #{video.id} processing failed (attempt #{attempt}/#{max}): #{inspect(reason)}")

    if attempt >= max, do: Videos.processing_failed(video)

    {:error, reason}
  end

  defp ensure_ffmpeg do
    if Media.available?(), do: :ok, else: {:error, :ffmpeg_not_installed}
  end

  defp maybe_transcode(video, info, source, dir) do
    if Media.web_ready?(info, video.video_key) do
      {:ok, %{}}
    else
      output = Path.join(dir, "video.mp4")
      key = "videos/#{video.id}/video.mp4"

      with :ok <- Media.transcode(source, output),
           :ok <- Storage.upload_file(Storage.bucket_videos(), key, output, "video/mp4") do
        if video.video_key != key, do: Storage.delete_object(Storage.bucket_videos(), video.video_key)
        {:ok, %{"video_key" => key}}
      end
    end
  end

  defp maybe_thumbnail(%Video{thumbnail_key: key}, _info, _source, _dir) when is_binary(key) and key != "",
    do: {:ok, %{}}

  defp maybe_thumbnail(video, info, source, dir) do
    output = Path.join(dir, "thumb.jpg")
    key = "thumbnails/#{video.id}/auto.jpg"

    with :ok <- Media.thumbnail(source, output, info.duration),
         :ok <- Storage.upload_file(Storage.bucket_thumbnails(), key, output, "image/jpeg") do
      {:ok, %{"thumbnail_key" => key}}
    else
      # A missing preview must not block publishing the video.
      error ->
        Logger.warning("Thumbnail for video #{video.id} failed: #{inspect(error)}")
        {:ok, %{}}
    end
  end

  defp duration_attrs(video, %{duration: duration}) when is_number(duration) do
    seconds = round(duration)
    attrs = %{"duration_seconds" => seconds}

    # JQ is limited to 3 minutes; longer clips are published as regular media.
    if video.format == "jq" and seconds > 180, do: Map.put(attrs, "format", "media"), else: attrs
  end

  defp duration_attrs(_video, _info), do: %{}
end
