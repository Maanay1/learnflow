defmodule Learnflow.VideosTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Repo
  alias Learnflow.Videos
  alias Learnflow.Videos.WatchProgress

  defp creator do
    {:ok, user} =
      Accounts.register_user(%{
        "username" => "creator_#{System.unique_integer([:positive])}",
        "email" => "creator#{System.unique_integer([:positive])}@example.com",
        "password" => "learn1234",
        "is_creator" => true
      })

    user
  end

  defp learner do
    {:ok, user} =
      Accounts.register_user(%{
        "username" => "learner_#{System.unique_integer([:positive])}",
        "email" => "learner#{System.unique_integer([:positive])}@example.com",
        "password" => "learn1234"
      })

    user
  end

  defp active_video(attrs \\ %{}) do
    c = creator()
    {:ok, video} = Videos.create_video(c, Map.merge(%{"title" => "Algebra Basics", "difficulty" => "beginner", "language" => "ru"}, attrs))
    {:ok, video} = Videos.confirm_upload(video, %{"video_key" => "videos/#{video.id}/source.mp4", "thumbnail_key" => "thumbnails/#{video.id}/thumb.jpg", "duration_seconds" => 120})
    video
  end

  test "create_video/2 creates pending video and generates url-safe slug" do
    c = creator()

    assert {:ok, video} = Videos.create_video(c, %{"title" => "Intro to Elixir!", "difficulty" => "beginner", "language" => "en"})
    assert video.status == "pending"
    assert video.creator_id == c.id
    assert video.slug =~ ~r/^intro-to-elixir-[a-f0-9-]{8}$/
  end

  test "request_upload_url/3 validates content type and returns key" do
    video = active_video()

    assert {:ok, url, key} = Videos.request_upload_url(video, "video/mp4", 100_000)
    assert key == "videos/#{video.id}/source.mp4"
    assert String.contains?(url, "learnflow-videos")
    assert {:error, :invalid_video_type} = Videos.request_upload_url(video, "video/avi", 100_000)
    assert {:error, :file_too_large} = Videos.request_upload_url(video, "video/mp4", 5_000_000_001)
  end

  test "get_feed/2 paginates with composite cursor" do
    first = active_video(%{"title" => "First Lesson"})
    second = active_video(%{"title" => "Second Lesson"})

    {page1, cursor} = Videos.get_feed(nil, %{"limit" => 1})
    assert length(page1) == 1
    assert cursor

    {page2, _cursor} = Videos.get_feed(nil, %{"limit" => 1, "cursor" => cursor})
    assert length(page2) == 1
    assert hd(page1).id != hd(page2).id
    assert Enum.sort([first.id, second.id]) == Enum.sort([hd(page1).id, hd(page2).id])
  end

  test "search_videos/2 uses full text search and filters" do
    video = active_video(%{"title" => "Quantum Mechanics", "difficulty" => "advanced", "language" => "en"})

    {:ok, video_id} = Ecto.UUID.dump(video.id)
    Repo.query!("UPDATE videos SET search_vector = setweight(to_tsvector('simple', title), 'A') || setweight(to_tsvector('simple', coalesce(description, '')), 'B') WHERE id = $1", [video_id])

    {results, _cursor} = Videos.search_videos("Quantum", %{"difficulty" => "advanced", "language" => "en"})
    assert Enum.any?(results, &(&1.id == video.id))
  end

  test "update_watch_progress/3 upserts progress" do
    user = learner()
    video = active_video()

    assert {:ok, %WatchProgress{seconds_watched: 10}} = Videos.update_watch_progress(user.id, video.id, 10)
    assert {:ok, %WatchProgress{seconds_watched: 42}} = Videos.update_watch_progress(user.id, video.id, 42)

    assert Repo.one(from p in WatchProgress, where: p.user_id == ^user.id and p.video_id == ^video.id, select: count()) == 1
  end
end
