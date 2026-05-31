defmodule Learnflow.Messaging do
  import Ecto.Query
  alias Ecto.Multi
  alias Learnflow.Accounts.User
  alias Learnflow.Messaging.{Conversation, ConversationMember, Message}
  alias Learnflow.Repo

  @message_limit 30

  def list_conversations(user_id) do
    Conversation
    |> join(:inner, [c], m in ConversationMember, on: m.conversation_id == c.id and m.user_id == ^user_id)
    |> order_by([c], desc: c.updated_at, desc: c.inserted_at)
    |> preload([:creator, members: :user])
    |> Repo.all()
    |> Enum.map(&decorate_conversation(&1, user_id))
  end

  def create_direct_conversation(%User{} = user, target_user_id) when user.id == target_user_id, do: {:error, :cannot_message_self}

  def create_direct_conversation(%User{} = user, target_user_id) do
    with %User{} <- Repo.get(User, target_user_id) do
      case existing_direct(user.id, target_user_id) do
        nil -> insert_direct(user.id, target_user_id)
        conversation -> {:ok, decorate_conversation(conversation, user.id)}
      end
    else
      nil -> {:error, :not_found}
    end
  end

  def create_group(%User{} = user, attrs) do
    Multi.new()
    |> Multi.insert(:conversation, Conversation.changeset(%Conversation{}, Map.merge(string_keys(attrs), %{"type" => "group", "creator_id" => user.id})))
    |> Multi.insert(:member, fn %{conversation: conversation} ->
      ConversationMember.changeset(%ConversationMember{}, %{conversation_id: conversation.id, user_id: user.id, role: "admin"})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{conversation: conversation}} ->
        attrs
        |> Map.get("member_ids", Map.get(attrs, :member_ids, []))
        |> Enum.uniq()
        |> Enum.reject(&(&1 == user.id))
        |> Enum.each(&add_member(user, conversation.id, &1))

        {:ok, get_conversation_for_user!(conversation.id, user.id)}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  def get_conversation_for_user(id, user_id) do
    Conversation
    |> join(:inner, [c], m in ConversationMember, on: m.conversation_id == c.id and m.user_id == ^user_id)
    |> where([c], c.id == ^id)
    |> preload([:creator, members: :user])
    |> Repo.one()
    |> case do
      nil -> nil
      conversation -> decorate_conversation(conversation, user_id)
    end
  end

  def member?(conversation_id, user_id) do
    Repo.exists?(from m in ConversationMember, where: m.conversation_id == ^conversation_id and m.user_id == ^user_id)
  end

  def admin?(conversation_id, user_id) do
    Repo.exists?(from m in ConversationMember, where: m.conversation_id == ^conversation_id and m.user_id == ^user_id and m.role == "admin")
  end

  def list_messages(conversation_id, user_id, cursor \\ nil) do
    if member?(conversation_id, user_id) do
      cursor_tuple = parse_cursor(cursor)

      query =
        from msg in Message,
          where: msg.conversation_id == ^conversation_id,
          order_by: [desc: msg.inserted_at, desc: msg.id],
          limit: ^(@message_limit + 1),
          preload: [:sender, shared_video: [:creator, :tags, :chapters]]

      query =
        case cursor_tuple do
          nil -> query
          {inserted_at, id} -> where(query, [msg], msg.inserted_at < ^inserted_at or (msg.inserted_at == ^inserted_at and msg.id < ^id))
        end

      rows = Repo.all(query)
      messages = rows |> Enum.take(@message_limit) |> Enum.reverse()
      next_cursor = if length(rows) > @message_limit, do: encode_cursor(rows |> Enum.take(@message_limit) |> List.last()), else: nil
      {:ok, messages, next_cursor}
    else
      {:error, :not_found}
    end
  end

  def send_message(%User{} = user, conversation_id, attrs) do
    if member?(conversation_id, user.id) do
      attrs =
        attrs
        |> string_keys()
        |> Map.merge(%{"conversation_id" => conversation_id, "sender_id" => user.id})
        |> normalize_message_type()

      with {:ok, message} <- %Message{} |> Message.changeset(attrs) |> Repo.insert() do
        message = Repo.preload(message, [:sender, shared_video: [:creator, :tags, :chapters]])
        touch_conversation(conversation_id)
        Phoenix.PubSub.broadcast(Learnflow.PubSub, "conversation:#{conversation_id}", {:new_message, message})
        {:ok, message}
      end
    else
      {:error, :not_found}
    end
  end

  def mark_read(user_id, conversation_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    {count, _} =
      Repo.update_all(
        from(m in ConversationMember, where: m.conversation_id == ^conversation_id and m.user_id == ^user_id),
        set: [last_read_at: now]
      )

    if count == 1 do
      Phoenix.PubSub.broadcast(Learnflow.PubSub, "conversation:#{conversation_id}", {:conversation_read, user_id, now})
      {:ok, now}
    else
      {:error, :not_found}
    end
  end

  def set_online(user_id) do
    Agent.update(Learnflow.Messaging.Online, &Map.update(&1, user_id, 1, fn count -> count + 1 end))
    :ok
  end

  def set_offline(user_id) do
    Agent.get_and_update(Learnflow.Messaging.Online, fn online ->
      case Map.get(online, user_id, 0) do
        count when count > 1 -> {:online, Map.put(online, user_id, count - 1)}
        _ -> {:offline, Map.delete(online, user_id)}
      end
    end)
  end

  def online_member_ids(conversation_id) do
    online = Agent.get(Learnflow.Messaging.Online, & &1)

    ConversationMember
    |> where([m], m.conversation_id == ^conversation_id)
    |> select([m], m.user_id)
    |> Repo.all()
    |> Enum.filter(&Map.has_key?(online, &1))
  end

  def add_member(%User{} = user, conversation_id, user_id) do
    with :ok <- require_admin(user.id, conversation_id),
         %Conversation{type: "group"} = conversation <- Repo.get(Conversation, conversation_id),
         %User{} <- Repo.get(User, user_id),
         :ok <- ensure_capacity(conversation) do
      %ConversationMember{}
      |> ConversationMember.changeset(%{conversation_id: conversation_id, user_id: user_id, role: "member"})
      |> Repo.insert(on_conflict: :nothing, conflict_target: [:conversation_id, :user_id])
    else
      %Conversation{} -> {:error, :not_group}
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def remove_member(%User{} = user, conversation_id, user_id) do
    with :ok <- require_admin(user.id, conversation_id) do
      {count, _} =
        Repo.delete_all(
          from m in ConversationMember,
            where: m.conversation_id == ^conversation_id and m.user_id == ^user_id
        )

      if count == 1, do: {:ok, :removed}, else: {:error, :not_found}
    end
  end

  def update_group(%User{} = user, conversation_id, attrs) do
    with :ok <- require_admin(user.id, conversation_id),
         %Conversation{type: "group"} = conversation <- Repo.get(Conversation, conversation_id),
         {:ok, updated} <- conversation |> Conversation.changeset(Map.take(string_keys(attrs), ["name", "description", "avatar_key", "max_members"])) |> Repo.update() do
      {:ok, get_conversation_for_user!(updated.id, user.id)}
    else
      %Conversation{} -> {:error, :not_group}
      nil -> {:error, :not_found}
      error -> error
    end
  end

  defp existing_direct(user_id, target_user_id) do
    Conversation
    |> where([c], c.type == "direct")
    |> join(:inner, [c], m1 in ConversationMember, on: m1.conversation_id == c.id and m1.user_id == ^user_id)
    |> join(:inner, [c], m2 in ConversationMember, on: m2.conversation_id == c.id and m2.user_id == ^target_user_id)
    |> preload([:creator, members: :user])
    |> Repo.one()
  end

  defp insert_direct(user_id, target_user_id) do
    Multi.new()
    |> Multi.insert(:conversation, Conversation.changeset(%Conversation{}, %{type: "direct", creator_id: user_id}))
    |> Multi.insert(:me, fn %{conversation: conversation} ->
      ConversationMember.changeset(%ConversationMember{}, %{conversation_id: conversation.id, user_id: user_id, role: "member"})
    end)
    |> Multi.insert(:other, fn %{conversation: conversation} ->
      ConversationMember.changeset(%ConversationMember{}, %{conversation_id: conversation.id, user_id: target_user_id, role: "member"})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{conversation: conversation}} -> {:ok, get_conversation_for_user!(conversation.id, user_id)}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  defp decorate_conversation(%Conversation{} = conversation, user_id) do
    conversation
    |> Map.put(:last_message, last_message(conversation.id))
    |> Map.put(:unread_count, unread_count(conversation.id, user_id))
  end

  defp get_conversation_for_user!(conversation_id, user_id), do: get_conversation_for_user(conversation_id, user_id)

  defp last_message(conversation_id) do
    Message
    |> where([m], m.conversation_id == ^conversation_id)
    |> order_by([m], desc: m.inserted_at, desc: m.id)
    |> limit(1)
    |> preload([:sender, shared_video: [:creator, :tags, :chapters]])
    |> Repo.one()
  end

  defp unread_count(conversation_id, user_id) do
    member = Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id)
    last_read_at = member && member.last_read_at

    query = from m in Message, where: m.conversation_id == ^conversation_id and m.sender_id != ^user_id

    query =
      case last_read_at do
        nil -> query
        value -> where(query, [m], m.inserted_at > ^value)
      end

    Repo.one(from m in query, select: count(m.id))
  end

  defp touch_conversation(conversation_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    Repo.update_all(from(c in Conversation, where: c.id == ^conversation_id), set: [updated_at: now])
  end

  defp require_admin(user_id, conversation_id), do: if(admin?(conversation_id, user_id), do: :ok, else: {:error, :forbidden})

  defp ensure_capacity(%Conversation{id: id, max_members: max_members}) do
    count = Repo.one(from m in ConversationMember, where: m.conversation_id == ^id, select: count())
    if count < max_members, do: :ok, else: {:error, :group_full}
  end

  defp normalize_message_type(attrs) do
    cond do
      Map.get(attrs, "message_type") -> attrs
      Map.get(attrs, "shared_video_id") -> Map.put(attrs, "message_type", "video_share")
      true -> Map.put(attrs, "message_type", "text")
    end
  end

  defp string_keys(map) when is_map(map), do: Map.new(map, fn {key, value} -> {to_string(key), value} end)
  defp string_keys(_), do: %{}

  defp encode_cursor(nil), do: nil
  defp encode_cursor(message), do: Base.url_encode64("#{DateTime.to_iso8601(message.inserted_at)}|#{message.id}", padding: false)
  defp parse_cursor(nil), do: nil
  defp parse_cursor(""), do: nil

  defp parse_cursor(cursor) do
    with {:ok, decoded} <- Base.url_decode64(cursor, padding: false),
         [timestamp, id] <- String.split(decoded, "|"),
         {:ok, inserted_at, _} <- DateTime.from_iso8601(timestamp) do
      {inserted_at, id}
    else
      _ -> nil
    end
  end

end
