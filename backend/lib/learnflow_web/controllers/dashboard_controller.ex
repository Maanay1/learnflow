defmodule LearnflowWeb.DashboardController do
  use LearnflowWeb, :controller
  alias Learnflow.Dashboard
  alias LearnflowWeb.VideoJSON

  def stats(conn, _), do: json(conn, Dashboard.get_user_stats(conn.assigns.current_user))

  def history(conn, params) do
    {items, next_cursor} = Dashboard.get_watch_history(conn.assigns.current_user, params["cursor"])
    json(conn, %{items: Enum.map(items, &history_json/1), next_cursor: next_cursor})
  end

  def delete_history(conn, %{"video_id" => id}) do
    with {:ok, status} <- Dashboard.delete_history_entry(conn.assigns.current_user, id) do
      json(conn, %{ok: true, status: status})
    end
  end

  def saved(conn, params) do
    {items, next_cursor} = Dashboard.get_saved_videos(conn.assigns.current_user, params["cursor"])
    json(conn, %{items: Enum.map(items, &saved_json/1), next_cursor: next_cursor})
  end

  def export(conn, _), do: json(conn, Dashboard.export(conn.assigns.current_user))

  defp history_json(row), do: %{seconds_watched: row.seconds_watched, completed: row.completed, last_watched_at: row.last_watched_at, video: VideoJSON.video(row.video)}
  defp saved_json(row), do: %{inserted_at: row.inserted_at, video: VideoJSON.video(row.video)}
end
