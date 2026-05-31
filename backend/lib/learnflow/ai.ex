defmodule Learnflow.AI do
  @moduledoc """
  OpenAI-powered enrichment for videos: subtitles, summaries, chapters and recommendations.
  """

  import Ecto.Query
  alias Learnflow.Repo
  alias Learnflow.Storage
  alias Learnflow.Videos
  alias Learnflow.Videos.{Video, VideoTag, WatchProgress}

  @audio_url "https://api.openai.com/v1/audio/transcriptions"
  @chat_url "https://api.openai.com/v1/chat/completions"
  @audio_limit 25_000_000

  def transcribe_video(video_key, language) do
    with %Video{} = video <- Repo.get_by(Video, video_key: video_key),
         {:ok, body} <- load_audio_sample(video_key),
         {:ok, vtt} <- whisper(body, language) do
      lang = normalize_language(language || video.language)
      key = subtitle_key(video.id, lang)

      with {:ok, _} <- Storage.put_object(Storage.bucket_videos(), key, vtt, "text/vtt") do
        langs = video.subtitle_languages |> normalize_languages() |> Enum.concat([lang]) |> Enum.uniq()

        video
        |> Video.changeset(%{has_subtitles: true, subtitle_languages: langs, ai_processed_at: utc_now()})
        |> Repo.update()

        {:ok, vtt}
      end
    else
      nil -> {:error, :video_not_found}
      error -> error
    end
  end

  def generate_summary(video_id) do
    with %Video{} = video <- Repo.get(Video, video_id),
         {:ok, transcript} <- transcript_text(video),
         {:ok, summary} <- summarize(transcript) do
      video
      |> Video.changeset(%{summary: summary, ai_processed_at: utc_now()})
      |> Repo.update()
      |> case do
        {:ok, _video} -> {:ok, summary}
        error -> error
      end
    else
      nil -> {:error, :video_not_found}
      error -> error
    end
  end

  def get_recommendations(user_id, limit \\ 10) do
    tags =
      Repo.all(
        from vt in VideoTag,
          join: wp in WatchProgress,
          on: wp.video_id == vt.video_id,
          where: wp.user_id == ^user_id,
          group_by: vt.tag_id,
          order_by: [desc: count(vt.video_id)],
          limit: 8,
          select: vt.tag_id
      )

    watched =
      Repo.all(from wp in WatchProgress, where: wp.user_id == ^user_id, select: wp.video_id)

    Video
    |> where([v], v.status == "active")
    |> where([v], v.id not in ^watched)
    |> maybe_recommend_tags(tags)
    |> order_by([v], [desc: v.view_count, desc: v.inserted_at])
    |> limit(^limit)
    |> preload([:creator, :tags])
    |> Repo.all()
  end

  def auto_generate_chapters(video_id) do
    with %Video{} = video <- Repo.get(Video, video_id),
         {:ok, vtt} <- transcript_vtt(video),
         {:ok, chapters} <- suggest_chapters(vtt) do
      normalized =
        chapters
        |> Enum.with_index(1)
        |> Enum.map(fn {chapter, index} ->
          %{
            "title" => to_string(chapter["title"] || chapter[:title] || "Глава #{index}"),
            "start_seconds" => to_integer(chapter["start_seconds"] || chapter[:start_seconds] || 0),
            "position" => index
          }
        end)

      Videos.add_chapters(video, normalized)
      {:ok, normalized}
    else
      nil -> {:error, :video_not_found}
      error -> error
    end
  end

  def subtitle_url(video_id, language) do
    lang = normalize_language(language)
    Storage.generate_download_url(Storage.bucket_videos(), subtitle_key(video_id, lang), "#{lang}.vtt")
  end

  def subtitle_key(video_id, language), do: "subtitles/#{video_id}/#{normalize_language(language)}.vtt"

  defp load_audio_sample(video_key) do
    with {:ok, body} <- Storage.get_object(Storage.bucket_videos(), video_key) do
      {:ok, binary_part(body, 0, min(byte_size(body), @audio_limit))}
    end
  end

  defp whisper(audio, language) do
    case api_key() do
      nil -> {:ok, fallback_vtt(language)}
      key -> post_multipart(key, audio, language)
    end
  end

  defp post_multipart(key, audio, language) do
    boundary = "learnflow-#{System.unique_integer([:positive])}"

    body =
      [
        part(boundary, "model", "whisper-1"),
        part(boundary, "response_format", "vtt"),
        part(boundary, "language", normalize_language(language)),
        file_part(boundary, "file", "source.mp4", "application/octet-stream", audio),
        "--#{boundary}--\r\n"
      ]
      |> IO.iodata_to_binary()

    headers = [
      {"authorization", "Bearer #{key}"},
      {"content-type", "multipart/form-data; boundary=#{boundary}"}
    ]

    Finch.build(:post, @audio_url, headers, body)
    |> Finch.request(Learnflow.Finch, receive_timeout: 120_000)
    |> case do
      {:ok, %{status: status, body: vtt}} when status in 200..299 -> {:ok, vtt}
      {:ok, %{status: status, body: body}} -> {:error, {:openai, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp summarize(transcript) do
    prompt = """
    Summarize this educational video transcript in 3-5 bullet points in Russian.
    Focus on key learning outcomes. Be concise.

    #{String.slice(transcript, 0, 18_000)}
    """

    chat(prompt, "Краткое содержание будет доступно после обработки transcript.")
  end

  defp suggest_chapters(vtt) do
    prompt = """
    Given this video transcript with timestamps, suggest 5-8 chapter titles with their start times.
    Return only a JSON array: [{"title":"...","start_seconds":0}].

    #{String.slice(vtt, 0, 18_000)}
    """

    case chat(prompt, "[]") do
      {:ok, content} ->
        content
        |> strip_code_fence()
        |> Jason.decode()
        |> case do
          {:ok, list} when is_list(list) and list != [] -> {:ok, list}
          _ -> {:ok, fallback_chapters(vtt)}
        end

      error ->
        error
    end
  end

  defp chat(prompt, fallback) do
    case api_key() do
      nil ->
        {:ok, fallback}

      key ->
        body =
          Jason.encode!(%{
            model: "gpt-4o-mini",
            messages: [
              %{role: "system", content: "You are a concise educational assistant."},
              %{role: "user", content: prompt}
            ],
            temperature: 0.2
          })

        headers = [{"authorization", "Bearer #{key}"}, {"content-type", "application/json"}]

        Finch.build(:post, @chat_url, headers, body)
        |> Finch.request(Learnflow.Finch, receive_timeout: 60_000)
        |> case do
          {:ok, %{status: status, body: body}} when status in 200..299 ->
            with {:ok, decoded} <- Jason.decode(body),
                 content when is_binary(content) <- get_in(decoded, ["choices", Access.at(0), "message", "content"]) do
              {:ok, String.trim(content)}
            else
              _ -> {:error, :invalid_openai_response}
            end

          {:ok, %{status: status, body: body}} ->
            {:error, {:openai, status, body}}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp transcript_text(video) do
    with {:ok, vtt} <- transcript_vtt(video) do
      text =
        vtt
        |> String.replace(~r/WEBVTT|NOTE.*|\d{2}:\d{2}:\d{2}\.\d{3}\s+-->\s+\d{2}:\d{2}:\d{2}\.\d{3}.*/, "")
        |> String.replace(~r/^\d+$/m, "")
        |> String.replace(~r/\n+/, " ")
        |> String.trim()

      {:ok, text}
    end
  end

  defp transcript_vtt(video) do
    lang = video.subtitle_languages |> normalize_languages() |> List.first() || video.language || "ru"
    Storage.get_object(Storage.bucket_videos(), subtitle_key(video.id, lang))
  end

  defp maybe_recommend_tags(query, []), do: query

  defp maybe_recommend_tags(query, tags) do
    from v in query,
      join: vt in VideoTag,
      on: vt.video_id == v.id,
      where: vt.tag_id in ^tags,
      distinct: v.id
  end

  defp normalize_languages(value) when is_list(value), do: Enum.map(value, &normalize_language/1)
  defp normalize_languages(_), do: []

  defp normalize_language(language) do
    language
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z-]/, "")
    |> case do
      "" -> "ru"
      lang -> String.slice(lang, 0, 10)
    end
  end

  defp api_key do
    Application.get_env(:learnflow, :openai, [])
    |> Keyword.get(:api_key)
    |> case do
      value when value in [nil, ""] -> nil
      value -> value
    end
  end

  defp part(boundary, name, value), do: ["--#{boundary}\r\ncontent-disposition: form-data; name=\"#{name}\"\r\n\r\n", value, "\r\n"]

  defp file_part(boundary, name, filename, content_type, body) do
    [
      "--#{boundary}\r\n",
      "content-disposition: form-data; name=\"#{name}\"; filename=\"#{filename}\"\r\n",
      "content-type: #{content_type}\r\n\r\n",
      body,
      "\r\n"
    ]
  end

  defp strip_code_fence(content) do
    content
    |> String.trim()
    |> String.replace(~r/^```(?:json)?\s*/i, "")
    |> String.replace(~r/\s*```$/, "")
    |> String.trim()
  end

  defp fallback_vtt(language) do
    """
    WEBVTT

    00:00:00.000 --> 00:00:06.000
    AI subtitles are queued. Add OPENAI_API_KEY to enable real #{normalize_language(language)} transcription.
    """
  end

  defp fallback_chapters(vtt) do
    Regex.scan(~r/(\d{2}):(\d{2}):(\d{2})\.\d{3}\s+-->/, vtt)
    |> Enum.take(6)
    |> Enum.with_index(1)
    |> Enum.map(fn {[_, hh, mm, ss], index} ->
      %{"title" => "Глава #{index}", "start_seconds" => to_integer(hh) * 3600 + to_integer(mm) * 60 + to_integer(ss)}
    end)
  end

  defp to_integer(value) when is_integer(value), do: value

  defp to_integer(value) do
    case Integer.parse(to_string(value)) do
      {n, _} -> n
      _ -> 0
    end
  end

  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)
end
