defmodule Learnflow.MessagingTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Messaging

  defp user(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Learnflow.Accounts.register_user(
        Map.merge(
          %{
            "username" => "msg_user_#{n}",
            "email" => "msg_user_#{n}@example.com",
            "password" => "learn1234"
          },
          attrs
        )
      )

    user
  end

  test "creates direct conversations once and sends paginated messages" do
    me = user()
    peer = user()

    assert {:ok, conversation} = Messaging.create_direct_conversation(me, peer.id)
    assert conversation.type == "direct"
    assert length(conversation.members) == 2

    assert {:ok, same_conversation} = Messaging.create_direct_conversation(me, peer.id)
    assert same_conversation.id == conversation.id

    Phoenix.PubSub.subscribe(Learnflow.PubSub, "conversation:#{conversation.id}")

    assert {:ok, message} = Messaging.send_message(me, conversation.id, %{"body" => "Hello"})
    assert_receive {:new_message, ^message}

    assert {:ok, [listed], nil} = Messaging.list_messages(conversation.id, peer.id)
    assert listed.body == "Hello"
    assert listed.sender_id == me.id
  end

  test "mark_read updates membership and removes unread count" do
    me = user()
    peer = user()
    {:ok, conversation} = Messaging.create_direct_conversation(me, peer.id)
    {:ok, _message} = Messaging.send_message(peer, conversation.id, %{"body" => "Read me"})

    [before_read] = Messaging.list_conversations(me.id)
    assert before_read.unread_count == 1

    assert {:ok, _at} = Messaging.mark_read(me.id, conversation.id)

    [after_read] = Messaging.list_conversations(me.id)
    assert after_read.unread_count == 0
  end

  test "group membership is admin controlled" do
    admin = user()
    member = user()
    stranger = user()

    assert {:ok, group} = Messaging.create_group(admin, %{"name" => "Phoenix Study", "description" => "Channels"})
    assert group.type == "group"
    assert Messaging.admin?(group.id, admin.id)

    assert {:ok, _member} = Messaging.add_member(admin, group.id, member.id)
    assert Messaging.member?(group.id, member.id)
    assert {:error, :forbidden} = Messaging.add_member(member, group.id, stranger.id)

    assert {:ok, updated} = Messaging.update_group(admin, group.id, %{"name" => "Realtime Study"})
    assert updated.name == "Realtime Study"

    assert {:ok, :removed} = Messaging.remove_member(admin, group.id, member.id)
    refute Messaging.member?(group.id, member.id)
  end
end
