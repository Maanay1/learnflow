defmodule LearnflowWeb.ConversationController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Messaging}
  alias LearnflowWeb.VideoJSON

  def index(conn, _params) do
    conversations = Messaging.list_conversations(conn.assigns.current_user.id)
    json(conn, %{conversations: Enum.map(conversations, &conversation_json(&1, conn.assigns.current_user.id))})
  end

  def create(conn, %{"user_id" => user_id}) do
    with {:ok, conversation} <- Messaging.create_direct_conversation(conn.assigns.current_user, user_id) do
      conn |> put_status(:created) |> json(%{conversation: conversation_json(conversation, conn.assigns.current_user.id)})
    end
  end

  def messages(conn, %{"id" => id} = params) do
    with {:ok, messages, next_cursor} <- Messaging.list_messages(id, conn.assigns.current_user.id, params["cursor"]) do
      json(conn, %{messages: Enum.map(messages, &message_json/1), next_cursor: next_cursor})
    end
  end

  def send_message(conn, %{"id" => id} = params) do
    with {:ok, message} <- Messaging.send_message(conn.assigns.current_user, id, params) do
      conn |> put_status(:created) |> json(%{message: message_json(message)})
    end
  end

  def read(conn, %{"id" => id}) do
    with {:ok, at} <- Messaging.mark_read(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, last_read_at: at})
    end
  end

  def create_group(conn, params) do
    with {:ok, conversation} <- Messaging.create_group(conn.assigns.current_user, params) do
      conn |> put_status(:created) |> json(%{conversation: conversation_json(conversation, conn.assigns.current_user.id)})
    end
  end

  def add_member(conn, %{"id" => id, "user_id" => user_id}) do
    with {:ok, _member} <- Messaging.add_member(conn.assigns.current_user, id, user_id) do
      json(conn, %{ok: true})
    end
  end

  def remove_member(conn, %{"id" => id, "user_id" => user_id}) do
    with {:ok, _} <- Messaging.remove_member(conn.assigns.current_user, id, user_id) do
      json(conn, %{ok: true})
    end
  end

  def update_group(conn, %{"id" => id} = params) do
    with {:ok, conversation} <- Messaging.update_group(conn.assigns.current_user, id, params) do
      json(conn, %{conversation: conversation_json(conversation, conn.assigns.current_user.id)})
    end
  end

  def conversation_json(conversation, current_user_id) do
    members = loaded_assoc(conversation, :members)
    peer = Enum.find(members, &(&1.user_id != current_user_id))

    %{
      id: conversation.id,
      type: conversation.type,
      name: conversation_name(conversation, peer),
      avatar_key: conversation.avatar_key || peer_avatar(peer),
      description: conversation.description,
      creator: conversation |> loaded_one(:creator) |> Accounts.public_user(),
      max_members: conversation.max_members,
      members: Enum.map(members, &member_json/1),
      last_message: conversation |> Map.get(:last_message) |> message_json(),
      unread_count: Map.get(conversation, :unread_count, 0),
      inserted_at: conversation.inserted_at,
      updated_at: conversation.updated_at
    }
  end

  def message_json(nil), do: nil

  def message_json(message) do
    %{
      id: message.id,
      conversation_id: message.conversation_id,
      sender: message |> loaded_one(:sender) |> Accounts.public_user(),
      sender_id: message.sender_id,
      body: message.body,
      message_type: message.message_type,
      shared_video: message |> loaded_one(:shared_video) |> VideoJSON.video(),
      read_at: message.read_at,
      inserted_at: message.inserted_at
    }
  end

  defp member_json(member) do
    %{
      user_id: member.user_id,
      role: member.role,
      joined_at: member.joined_at,
      last_read_at: member.last_read_at,
      user: member |> loaded_one(:user) |> Accounts.public_user()
    }
  end

  defp conversation_name(%{type: "group", name: name}, _peer), do: name
  defp conversation_name(_conversation, %{user: user}) when not is_nil(user), do: user.display_name || user.username
  defp conversation_name(_conversation, _peer), do: "Чат"

  defp peer_avatar(%{user: %{avatar_key: avatar_key}}), do: avatar_key
  defp peer_avatar(_peer), do: nil

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
