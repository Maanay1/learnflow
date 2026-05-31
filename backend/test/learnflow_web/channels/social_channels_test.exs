defmodule LearnflowWeb.SocialChannelsTest do
  use LearnflowWeb.ChannelCase, async: false

  alias Learnflow.Accounts
  alias Learnflow.Notifications
  alias Learnflow.Social
  alias Learnflow.Videos
  alias LearnflowWeb.{FeedChannel, NotificationChannel, UserSocket, VideoChannel}

  defp user(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Accounts.register_user(
        Map.merge(
          %{
            "username" => "channel_#{n}",
            "email" => "channel_#{n}@example.com",
            "password" => "learn1234"
          },
          attrs
        )
      )

    user
  end

  defp active_video do
    creator = user(%{"is_creator" => true})
    {:ok, video} = Videos.create_video(creator, %{"title" => "Channel Social", "difficulty" => "beginner", "language" => "ru"})
    {:ok, video} = Videos.confirm_upload(video, %{"video_key" => "videos/#{video.id}/source.mp4", "duration_seconds" => 60})
    {creator, video}
  end

  defp socket_for(user) do
    socket(UserSocket, "users_socket:#{user.id}", %{current_user: user})
  end

  test "video channel pushes real-time comments, likes, and saves" do
    learner = user()
    {_creator, video} = active_video()

    {:ok, _, _socket} = socket_for(learner) |> subscribe_and_join(VideoChannel, "video:#{video.id}")

    {:ok, _comment} = Social.create_comment(learner.id, video.id, "Live comment")
    assert_push "new_comment", %{comment: %{body: "Live comment"}}

    {:ok, :liked} = Social.like_video(learner.id, video.id)
    assert_push "like_updated", %{count: 1}

    {:ok, :saved} = Social.save_video(learner.id, video.id)
    assert_push "save_updated", %{user_id: user_id, saved: true}
    assert user_id == learner.id
  end

  test "feed channel broadcasts new videos and like counts" do
    learner = user()
    {_creator, video} = active_video()

    {:ok, _, _socket} = socket_for(learner) |> subscribe_and_join(FeedChannel, "feed:lobby")
    flush_messages()

    Phoenix.PubSub.broadcast(Learnflow.PubSub, "feed:lobby", {:new_video, video})
    assert_push "new_video", %{video: %{id: video_id}}
    assert video_id == video.id

    Phoenix.PubSub.broadcast(Learnflow.PubSub, "feed:lobby", {:like_updated, video.id, 7})
    assert_push "like_updated", %{video_id: video_id, count: 7}
    assert video_id == video.id
  end

  test "notification channel only joins own topic and pushes new notifications" do
    recipient = user()
    other = user()

    assert {:error, %{reason: "unauthorized"}} =
             socket_for(recipient)
             |> subscribe_and_join(NotificationChannel, "notifications:#{other.id}")

    {:ok, _, _socket} = socket_for(recipient) |> subscribe_and_join(NotificationChannel, "notifications:#{recipient.id}")

    {:ok, _notification} = Notifications.create_notification(recipient.id, "new_follower", %{actor_id: other.id})
    assert_push "new_notification", %{notification: %{type: "new_follower"}}
  end

  defp flush_messages do
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end
  end
end
