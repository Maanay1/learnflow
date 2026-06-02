defmodule LearnflowWeb.VideoJSON do
  alias Learnflow.Accounts
  alias Learnflow.Social

  def video(nil), do: nil

  def video(v) do
    counts = Social.counts(v.id)

    %{
      id: v.id,
      title: v.title,
      description: v.description,
      slug: v.slug,
      status: v.status,
      format: v.format,
      difficulty: v.difficulty,
      language: v.language,
      duration_seconds: v.duration_seconds,
      video_key: v.video_key,
      thumbnail_url: Map.get(v, :thumbnail_url),
      view_url: Map.get(v, :view_url),
      view_count: v.view_count,
      like_count: counts.likes,
      comment_count: counts.comments,
      has_subtitles: Map.get(v, :has_subtitles, false),
      subtitle_languages: Map.get(v, :subtitle_languages, []),
      summary: Map.get(v, :summary),
      ai_processed_at: Map.get(v, :ai_processed_at),
      is_liked: Map.get(v, :is_liked, false),
      is_saved: Map.get(v, :is_saved, false),
      creator: v |> loaded_one(:creator) |> Accounts.public_user(),
      tags: Enum.map(loaded_assoc(v, :tags), &Map.take(&1, [:id, :name, :slug, :color])),
      chapters:
        Enum.map(
          loaded_assoc(v, :chapters),
          &Map.take(&1, [:id, :title, :start_seconds, :position])
        )
    }
  end

  def progress(nil), do: nil

  def progress(progress) do
    %{
      user_id: progress.user_id,
      video_id: progress.video_id,
      seconds_watched: progress.seconds_watched || 0,
      completed: progress.completed || false,
      last_watched_at: progress.last_watched_at
    }
  end

  defp loaded_assoc(struct, field) do
    case Map.get(struct, field) do
      %Ecto.Association.NotLoaded{} -> []
      nil -> []
      values -> values
    end
  end

  defp loaded_one(struct, field) do
    case Map.get(struct, field) do
      %Ecto.Association.NotLoaded{} -> nil
      value -> value
    end
  end
end
