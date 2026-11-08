defmodule Learnflow.Media do
  @moduledoc """
  ffmpeg/ffprobe helpers: inspect uploaded videos, convert them to a
  browser-friendly MP4 (H.264 + AAC) and extract a preview frame.
  """

  # Longest side of transcoded videos. 1280 keeps 720p quality while staying
  # fast enough for small server instances.
  @max_dimension 1280

  def available? do
    not is_nil(System.find_executable("ffmpeg")) and not is_nil(System.find_executable("ffprobe"))
  end

  @doc "Returns %{duration: seconds, video_codec:, audio_codec:, pix_fmt:, width:, height:}."
  def probe(path) do
    args = ["-v", "error", "-print_format", "json", "-show_format", "-show_streams", path]

    with {:ok, output} <- run("ffprobe", args),
         {:ok, data} <- Jason.decode(output) do
      streams = Map.get(data, "streams", [])
      video = Enum.find(streams, &(&1["codec_type"] == "video"))
      audio = Enum.find(streams, &(&1["codec_type"] == "audio"))

      if video do
        {:ok,
         %{
           duration: parse_duration(get_in(data, ["format", "duration"]) || video["duration"]),
           video_codec: video["codec_name"],
           audio_codec: audio && audio["codec_name"],
           pix_fmt: video["pix_fmt"],
           width: video["width"],
           height: video["height"]
         }}
      else
        {:error, :no_video_stream}
      end
    end
  end

  @doc "True when the file already plays in every browser/WebView without conversion."
  def web_ready?(info, key) do
    String.ends_with?(String.downcase(key), ".mp4") and
      info.video_codec == "h264" and
      info.pix_fmt in ["yuv420p", "yuvj420p"] and
      info.audio_codec in [nil, "aac", "mp3"] and
      (info.width || 0) <= 1920 and (info.height || 0) <= 1920
  end

  def transcode(source, destination) do
    scale =
      "scale=w='min(#{@max_dimension},iw)':h='min(#{@max_dimension},ih)':" <>
        "force_original_aspect_ratio=decrease:force_divisible_by=2,format=yuv420p"

    args = [
      "-y", "-hide_banner", "-loglevel", "error",
      "-i", source,
      "-map", "0:v:0", "-map", "0:a:0?",
      "-vf", scale,
      "-c:v", "libx264", "-preset", "veryfast", "-crf", "26", "-profile:v", "high",
      "-c:a", "aac", "-b:a", "128k", "-ac", "2",
      "-movflags", "+faststart",
      "-threads", "2",
      "-max_muxing_queue_size", "1024",
      destination
    ]

    with {:ok, _} <- run("ffmpeg", args), do: :ok
  end

  def thumbnail(source, destination, duration) do
    at = if is_number(duration) and duration > 2, do: min(duration / 3, 3.0), else: 0.0

    args = [
      "-y", "-hide_banner", "-loglevel", "error",
      "-ss", :erlang.float_to_binary(at * 1.0, decimals: 2),
      "-i", source,
      "-frames:v", "1",
      "-vf", "scale=w='min(720,iw)':h=-2",
      "-q:v", "4",
      destination
    ]

    with {:ok, _} <- run("ffmpeg", args),
         true <- File.exists?(destination) || {:error, :thumbnail_not_created} do
      :ok
    end
  end

  defp run(command, args) do
    case System.find_executable(command) do
      nil ->
        {:error, {:missing_executable, command}}

      executable ->
        # ffprobe prints JSON on stdout; keep its stderr out of the parsed output.
        case System.cmd(executable, args, stderr_to_stdout: command == "ffmpeg") do
          {output, 0} -> {:ok, output}
          {output, status} -> {:error, {command, status, String.slice(output, -500, 500)}}
        end
    end
  end

  defp parse_duration(nil), do: nil

  defp parse_duration(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> nil
    end
  end

  defp parse_duration(value) when is_number(value), do: value * 1.0
end
