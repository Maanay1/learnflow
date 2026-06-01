defmodule LearnflowWeb.VideoController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Dashboard, Payments, Videos}
  alias LearnflowWeb.CourseJSON
  alias LearnflowWeb.VideoJSON

  def create(conn, params) do
    user = conn.assigns.current_user

    with {:ok, video} <- Videos.create_video(user, params) do
      conn
      |> put_status(:created)
      |> json(%{video: VideoJSON.video(video)})
    end
  end

  def show(conn, %{"slug" => slug}) do
    viewer = optional_viewer(conn)
    session = optional_session(conn)

    case Videos.get_video_by_slug(slug, viewer && viewer.id) do
      nil ->
        {:error, :not_found}

      video ->
        view_url =
          if viewer && session do
            Videos.get_video_view_url(video, viewer, session.id)
          else
            Videos.get_public_video_view_url(video)
          end

        video =
          case view_url do
            {:ok, url} -> Map.put(video, :view_url, url)
            _ -> video
          end

        json(conn, %{video: VideoJSON.video(video)})
    end
  end

  def upload_url(conn, %{"id" => id} = params) do
    with {:ok, video} <- creator_video(conn, id),
         {:ok, url, key} <- Videos.request_upload_url(video, params["content_type"], params["file_size_bytes"]) do
      json(conn, %{upload_url: url, key: key})
    end
  end

  def thumbnail_url(conn, %{"id" => id} = params) do
    with {:ok, video} <- creator_video(conn, id),
         {:ok, url, key} <- Videos.request_thumbnail_upload_url(video, params["content_type"]) do
      json(conn, %{upload_url: url, key: key})
    end
  end

  def confirm(conn, %{"id" => id} = params) do
    with {:ok, video} <- creator_video(conn, id),
         {:ok, video} <- Videos.confirm_upload(video, params) do
      Phoenix.PubSub.broadcast(Learnflow.PubSub, "feed:lobby", {:new_video, video})
      json(conn, %{video: VideoJSON.video(video)})
    end
  end

  def chapters(conn, %{"id" => id, "chapters" => chapters}) do
    with {:ok, video} <- creator_video(conn, id),
         {:ok, inserted} <- Videos.add_chapters(video, chapters) do
      json(conn, %{chapters: Enum.map(inserted, &Map.take(&1, [:id, :title, :start_seconds, :position]))})
    end
  end

  def view_url(conn, %{"id" => id}) do
    with {:ok, video} <- active_video(id),
         :ok <- authorize_video_access(conn.assigns.current_user.id, video.id),
         {:ok, url} <- Videos.get_video_view_url(video, conn.assigns.current_user, conn.assigns.current_session.id) do
      json(conn, %{view_url: url})
    end
  end

  def progress(conn, %{"id" => id, "seconds_watched" => seconds}) do
    with {:ok, progress} <- Videos.update_watch_progress(conn.assigns.current_user.id, id, seconds) do
      json(conn, %{progress: VideoJSON.progress(progress)})
    end
  end

  def progress(conn, %{"id" => id}) do
    progress = Videos.get_watch_progress(conn.assigns.current_user.id, id)
    json(conn, %{progress: VideoJSON.progress(progress)})
  end

  def complete(conn, %{"id" => id}) do
    with {:ok, progress} <- Videos.mark_completed(conn.assigns.current_user.id, id) do
      completed_courses = Dashboard.completed_courses_for_video(conn.assigns.current_user.id, id)

      json(conn, %{
        progress: VideoJSON.progress(progress),
        completed_courses:
          Enum.map(completed_courses, fn item ->
            %{
              course: CourseJSON.course(item.course),
              certificate: CourseJSON.certificate(item.certificate)
            }
          end)
      })
    end
  end

  defp creator_video(conn, id) do
    user = conn.assigns.current_user
    user_id = user.id
    video = Videos.get_video_by_id(id)

    cond do
      match?(%{creator_id: ^user_id}, video) ->
        {:ok, video}

      true ->
        {:error, :not_found}
    end
  end

  defp active_video(id) do
    case Videos.get_video_by_id(id) do
      %{status: "active"} = video -> {:ok, video}
      _ -> {:error, :not_found}
    end
  end

  defp authorize_video_access(user_id, video_id) do
    if Payments.video_access?(user_id, video_id), do: :ok, else: {:error, :payment_required}
  end

  defp optional_viewer(conn) do
    conn = fetch_cookies(conn)
    conn.assigns[:current_user] || Accounts.get_user_by_session_token(conn.req_cookies["session_token"])
  end

  defp optional_session(conn) do
    conn = fetch_cookies(conn)
    conn.assigns[:current_session] || Accounts.get_session_by_token(conn.req_cookies["session_token"])
  end
end
