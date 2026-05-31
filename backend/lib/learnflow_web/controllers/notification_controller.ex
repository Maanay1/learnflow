defmodule LearnflowWeb.NotificationController do
  use LearnflowWeb, :controller
  alias Learnflow.Notifications
  alias LearnflowWeb.NotificationJSON

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    {items, next_cursor, unread_count} = Notifications.list_notifications(user_id, params["cursor"])

    json(conn, %{
      notifications: Enum.map(items, &NotificationJSON.notification/1),
      next_cursor: next_cursor,
      unread_count: unread_count
    })
  end

  def unread_count(conn, _params), do: json(conn, %{unread_count: Notifications.unread_count(conn.assigns.current_user.id)})

  def mark_read(conn, %{"id" => id}) do
    with {:ok, notification} <- Notifications.mark_read(conn.assigns.current_user.id, id) do
      json(conn, %{notification: NotificationJSON.notification(notification)})
    end
  end

  def mark_all_read(conn, _params) do
    {:ok, count} = Notifications.mark_all_read(conn.assigns.current_user.id)
    json(conn, %{ok: true, count: count})
  end

  def unsubscribe(conn, %{"user_id" => user_id}) do
    Notifications.unsubscribe(user_id)
    html(conn, "Email notifications disabled.")
  end
end
