defmodule LearnflowWeb.VideoChannel do
  use LearnflowWeb, :channel
  alias LearnflowWeb.SocialController

  @impl true
  def join("video:" <> video_id, _payload, socket) do
    if socket.assigns[:current_user] do
      Phoenix.PubSub.subscribe(Learnflow.PubSub, "video:#{video_id}")
      {:ok, assign(socket, :video_id, video_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:new_comment, comment}, socket) do
    push(socket, "new_comment", %{comment: SocialController.comment_json(comment)})
    {:noreply, socket}
  end

  def handle_info({:like_added, count}, socket) do
    push(socket, "like_updated", %{count: count})
    {:noreply, socket}
  end

  def handle_info({:like_removed, count}, socket) do
    push(socket, "like_updated", %{count: count})
    {:noreply, socket}
  end

  def handle_info({:save_added, user_id}, socket) do
    push(socket, "save_updated", %{user_id: user_id, saved: true})
    {:noreply, socket}
  end

  def handle_info({:save_removed, user_id}, socket) do
    push(socket, "save_updated", %{user_id: user_id, saved: false})
    {:noreply, socket}
  end
end
