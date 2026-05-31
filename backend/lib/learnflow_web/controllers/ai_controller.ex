defmodule LearnflowWeb.AIController do
  use LearnflowWeb, :controller

  alias Learnflow.AI
  alias Learnflow.Videos
  alias Learnflow.Workers.TranscribeVideoJob
  alias LearnflowWeb.VideoJSON

  def recommendations(conn, params) do
    limit = params["limit"] |> to_integer(10) |> min(20)
    videos = AI.get_recommendations(conn.assigns.current_user.id, limit)
    json(conn, %{items: Enum.map(videos, &VideoJSON.video/1)})
  end

  def subtitles(conn, %{"id" => id, "lang" => lang}) do
    with {:ok, video} <- active_video(id),
         true <- lang in normalize_languages(video.subtitle_languages),
         {:ok, url} <- AI.subtitle_url(video.id, lang) do
      json(conn, %{url: url, language: lang})
    else
      false -> conn |> put_status(:not_found) |> json(%{error: "subtitles_not_found"})
      _ -> conn |> put_status(:not_found) |> json(%{error: "subtitles_not_found"})
    end
  end

  def transcribe(conn, %{"id" => id}) do
    with {:ok, video} <- creator_video(conn, id),
         {:ok, _job} <- %{video_id: video.id} |> TranscribeVideoJob.new(schedule_in: 1) |> Oban.insert() do
      json(conn, %{status: "queued"})
    end
  end

  def summary(conn, %{"id" => id}) do
    case Videos.get_video_by_id(id) do
      %{status: "active"} = video -> json(conn, %{summary: video.summary})
      _ -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
    end
  end

  defp creator_video(conn, id) do
    user = conn.assigns.current_user

    case Videos.get_video_by_id(id) do
      %{creator_id: creator_id} = video when user.is_creator and creator_id == user.id -> {:ok, video}
      _ -> {:error, :not_found}
    end
  end

  defp active_video(id) do
    case Videos.get_video_by_id(id) do
      %{status: "active"} = video -> {:ok, video}
      _ -> {:error, :not_found}
    end
  end

  defp normalize_languages(value) when is_list(value), do: Enum.map(value, &to_string/1)
  defp normalize_languages(_), do: []

  defp to_integer(nil, default), do: default

  defp to_integer(value, default) do
    case Integer.parse(to_string(value)) do
      {number, _} -> number
      _ -> default
    end
  end
end
