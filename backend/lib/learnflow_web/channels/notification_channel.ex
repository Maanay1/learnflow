defmodule LearnflowWeb.NotificationChannel do
  use LearnflowWeb, :channel
  alias LearnflowWeb.NotificationJSON

  @impl true
  def join("notifications:" <> user_id, _payload, socket) do
    if socket.assigns.current_user.id == user_id do
      Phoenix.PubSub.subscribe(Learnflow.PubSub, "notifications:#{user_id}")
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:new_notification, notification}, socket) do
    push(socket, "new_notification", %{notification: NotificationJSON.notification(notification)})
    {:noreply, socket}
  end
end
