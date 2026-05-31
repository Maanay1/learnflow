defmodule LearnflowWeb.CourseController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Dashboard}
  alias LearnflowWeb.CourseJSON

  def index(conn, params) do
    user = optional_viewer(conn)
    courses = Dashboard.list_courses(params, user && user.id)
    json(conn, %{courses: Enum.map(courses, &CourseJSON.course/1)})
  end

  def show(conn, %{"slug" => slug}) do
    user = optional_viewer(conn)

    case Dashboard.get_course_by_slug(slug, user && user.id) do
      nil -> {:error, :not_found}
      course -> json(conn, %{course: CourseJSON.course(course)})
    end
  end

  def create(conn, params) do
    user = conn.assigns.current_user

    if user.is_creator do
      with {:ok, course} <- Dashboard.create_course(user, params) do
        conn |> put_status(:created) |> json(%{course: CourseJSON.course(course)})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "creator_required"})
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, course} <- Dashboard.creator_course(conn.assigns.current_user, id),
         {:ok, course} <- Dashboard.update_course(course, params) do
      json(conn, %{course: CourseJSON.course(course)})
    end
  end

  def publish(conn, %{"id" => id}) do
    with {:ok, course} <- Dashboard.creator_course(conn.assigns.current_user, id),
         {:ok, course} <- Dashboard.publish_course(course) do
      json(conn, %{course: CourseJSON.course(course)})
    end
  end

  def add_video(conn, %{"id" => id, "video_id" => video_id} = params) do
    with {:ok, course} <- Dashboard.creator_course(conn.assigns.current_user, id),
         {:ok, _} <- Dashboard.add_video_to_course(course, video_id, params["position"]) do
      json(conn, %{ok: true})
    end
  end

  def reorder(conn, %{"id" => id, "video_ids" => video_ids}) do
    with {:ok, course} <- Dashboard.creator_course(conn.assigns.current_user, id),
         {:ok, :ok} <- Dashboard.reorder_course_videos(course, video_ids) do
      json(conn, %{ok: true})
    end
  end

  def progress(conn, %{"id" => id}) do
    progress = Dashboard.get_course_progress(conn.assigns.current_user.id, id)
    json(conn, %{progress: %{completed: progress.completed, total: progress.total, percent: progress.percent, next_video: LearnflowWeb.VideoJSON.video(progress.next_video)}})
  end

  def my_courses(conn, _params) do
    courses = Dashboard.my_courses(conn.assigns.current_user)
    json(conn, %{courses: Enum.map(courses, &CourseJSON.course/1)})
  end

  defp optional_viewer(conn) do
    conn = fetch_cookies(conn)
    conn.assigns[:current_user] || Accounts.get_user_by_session_token(conn.req_cookies["session_token"])
  end
end
