defmodule LearnflowWeb.NotificationJSON do
  alias Learnflow.Accounts
  alias Learnflow.Notifications

  def notification(notification) do
    %{
      id: notification.id,
      type: notification.type,
      text: Notifications.text(notification),
      read_at: notification.read_at,
      inserted_at: notification.inserted_at,
      actor: notification |> loaded_one(:actor) |> Accounts.public_user(),
      video: video(loaded_one(notification, :video)),
      course: course(loaded_one(notification, :course)),
      comment_id: notification.comment_id
    }
  end

  defp video(nil), do: nil
  defp video(video), do: Map.take(video, [:id, :title, :slug])
  defp course(nil), do: nil
  defp course(course), do: Map.take(course, [:id, :title, :slug])

  defp loaded_one(struct, field) do
    case Map.get(struct, field) do
      %Ecto.Association.NotLoaded{} -> nil
      value -> value
    end
  end
end
