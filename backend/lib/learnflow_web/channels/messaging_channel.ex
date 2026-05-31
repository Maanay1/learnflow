defmodule LearnflowWeb.MessagingChannel do
  use LearnflowWeb, :channel
  alias Learnflow.Messaging
  alias LearnflowWeb.ConversationController

  @impl true
  def join("conversation:" <> conversation_id, _payload, socket) do
    user = socket.assigns[:current_user]

    if user && Messaging.member?(conversation_id, user.id) do
      Messaging.set_online(user.id)
      socket = assign(socket, :conversation_id, conversation_id)
      send(self(), :after_join_presence)
      {:ok, %{online_user_ids: Messaging.online_member_ids(conversation_id)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("new_message", payload, socket) do
    case Messaging.send_message(socket.assigns.current_user, socket.assigns.conversation_id, payload) do
      {:ok, message} -> {:reply, {:ok, %{message: ConversationController.message_json(message)}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  def handle_in("read", _payload, socket) do
    case Messaging.mark_read(socket.assigns.current_user.id, socket.assigns.conversation_id) do
      {:ok, at} -> {:reply, {:ok, %{last_read_at: at}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  def handle_in("typing", payload, socket) do
    broadcast_from(socket, "typing", %{
      user: Learnflow.Accounts.public_user(socket.assigns.current_user),
      is_typing: Map.get(payload, "is_typing", true)
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join_presence, socket) do
    broadcast_from(socket, "presence", %{user_id: socket.assigns.current_user.id, online: true})
    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    push(socket, "new_message", %{message: ConversationController.message_json(message)})
    {:noreply, socket}
  end

  def handle_info({:conversation_read, user_id, at}, socket) do
    push(socket, "read", %{user_id: user_id, last_read_at: at})
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    if socket.assigns[:current_user] do
      if Messaging.set_offline(socket.assigns.current_user.id) == :offline do
        broadcast_from(socket, "presence", %{user_id: socket.assigns.current_user.id, online: false})
      end
    end

    :ok
  end
end
