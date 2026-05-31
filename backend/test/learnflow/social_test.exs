defmodule Learnflow.SocialTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Social
  alias Learnflow.Videos

  defp user(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Accounts.register_user(
        Map.merge(
          %{
            "username" => "user_#{n}",
            "email" => "user#{n}@example.com",
            "password" => "learn1234"
          },
          attrs
        )
      )

    user
  end

  defp video do
    creator = user(%{"is_creator" => true})
    {:ok, video} = Videos.create_video(creator, %{"title" => "Social Learning", "difficulty" => "beginner", "language" => "ru"})
    {:ok, video} = Videos.confirm_upload(video, %{"video_key" => "videos/#{video.id}/source.mp4", "duration_seconds" => 60})
    {creator, video}
  end

  test "follow/unfollow lifecycle" do
    follower = user()
    following = user()

    assert {:error, :cannot_follow_self} = Social.follow(follower.id, follower.id)
    assert {:ok, :followed} = Social.follow(follower.id, following.id)
    assert Social.is_following?(follower.id, following.id)
    assert Social.get_followers_count(following.id) == 1
    assert Social.get_following_count(follower.id) == 1
    assert {:error, :already_following} = Social.follow(follower.id, following.id)
    assert {:ok, :unfollowed} = Social.unfollow(follower.id, following.id)
    refute Social.is_following?(follower.id, following.id)
    assert {:error, :not_following} = Social.unfollow(follower.id, following.id)
  end

  test "like/unlike updates count and publishes" do
    learner = user()
    {_creator, video} = video()
    Phoenix.PubSub.subscribe(Learnflow.PubSub, "video:#{video.id}")

    assert Social.get_like_count(video.id) == 0
    assert {:ok, :liked} = Social.like_video(learner.id, video.id)
    assert_receive {:like_added, 1}
    assert Social.is_liked?(learner.id, video.id)
    assert Social.get_like_count(video.id) == 1
    assert {:error, :already_liked} = Social.like_video(learner.id, video.id)
    assert {:ok, :unliked} = Social.unlike_video(learner.id, video.id)
    assert_receive {:like_removed, 0}
    assert Social.get_like_count(video.id) == 0
    assert {:error, :not_liked} = Social.unlike_video(learner.id, video.id)
  end

  test "create_comment enforces reply depth and list_comments includes replies" do
    learner = user()
    {_creator, video} = video()

    assert {:ok, parent} = Social.create_comment(learner.id, video.id, "Great lesson")
    assert {:ok, reply} = Social.create_comment(learner.id, video.id, "Agreed", parent.id)
    assert {:error, :max_depth} = Social.create_comment(learner.id, video.id, "Too deep", reply.id)

    {comments, nil} = Social.list_comments(video.id)
    listed_parent = Enum.find(comments, &(&1.id == parent.id))

    assert listed_parent
    assert Enum.any?(listed_parent.replies, &(&1.id == reply.id))
  end

  test "delete_comment allows owner and soft deletes" do
    learner = user()
    {_creator, video} = video()
    {:ok, comment} = Social.create_comment(learner.id, video.id, "Remove me")

    assert {:ok, deleted} = Social.delete_comment(learner.id, comment.id)
    assert deleted.is_deleted
    assert deleted.body == "[deleted]"
  end
end
