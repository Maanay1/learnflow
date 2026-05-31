defmodule LearnflowWeb.CourseJSON do
  alias Learnflow.Accounts
  alias LearnflowWeb.VideoJSON

  def course(nil), do: nil

  def course(course) do
    %{
      id: course.id,
      title: course.title,
      description: course.description,
      slug: course.slug,
      status: course.status,
      difficulty: course.difficulty,
      is_paid: course.is_paid,
      price_cents: course.price_cents,
      access: Map.get(course, :access),
      thumbnail_url: Map.get(course, :thumbnail_url),
      video_count: Map.get(course, :video_count, 0),
      duration_seconds: Map.get(course, :duration_seconds, 0),
      students_count: Map.get(course, :students_count, 0),
      progress: progress(Map.get(course, :progress)),
      certificate: maybe_certificate(Map.get(course, :certificate)),
      creator: course |> loaded_one(:user) |> Accounts.public_user(),
      subject_tag: course |> loaded_one(:subject_tag) |> tag(),
      videos: videos(course)
    }
  end

  def certificate(certificate) do
    %{
      id: certificate.id,
      certificate_number: certificate.certificate_number,
      issued_at: certificate.issued_at,
      course_id: certificate.playlist_id
    }
  end

  defp maybe_certificate(nil), do: nil
  defp maybe_certificate(certificate), do: certificate(certificate)

  defp videos(course) do
    course
    |> loaded_assoc(:playlist_videos)
    |> Enum.map(fn playlist_video ->
      playlist_video.video
      |> VideoJSON.video()
      |> Map.put(:position, playlist_video.position)
    end)
  end

  defp progress(nil), do: nil
  defp progress(progress) do
    %{
      completed: progress.completed,
      total: progress.total,
      percent: progress.percent,
      next_video: VideoJSON.video(progress.next_video)
    }
  end

  defp tag(nil), do: nil
  defp tag(tag), do: Map.take(tag, [:id, :name, :slug, :color])

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
