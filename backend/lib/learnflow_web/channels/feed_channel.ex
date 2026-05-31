defmodule LearnflowWeb.FeedChannel do
  use LearnflowWeb, :channel
  alias LearnflowWeb.VideoJSON

  @impl true
  def join("feed:lobby", _payload, socket) do
    if socket.assigns[:current_user] do
      Phoenix.PubSub.subscribe(Learnflow.PubSub, "feed:lobby")
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:new_video, video}, socket) do
    push(socket, "new_video", %{video: VideoJSON.video(video)})
    {:noreply, socket}
  end

  def handle_info({:like_updated, video_id, count}, socket) do
    push(socket, "like_updated", %{video_id: video_id, count: count})
    {:noreply, socket}
  end
end
