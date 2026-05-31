defmodule Learnflow.DashboardTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Dashboard
  alias Learnflow.Repo
  alias Learnflow.Videos
  alias Learnflow.Videos.WatchProgress

  defp user do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Accounts.register_user(%{
        "username" => "streak_#{n}",
        "email" => "streak#{n}@example.com",
        "password" => "learn1234"
      })

    user
  end

  defp video(title) do
    n = System.unique_integer([:positive])

    {:ok, creator} =
      Accounts.register_user(%{
        "username" => "creator_streak_#{n}",
        "email" => "creator_streak#{n}@example.com",
        "password" => "learn1234",
        "is_creator" => true
      })

    {:ok, video} = Videos.create_video(creator, %{"title" => title, "difficulty" => "beginner", "language" => "ru"})
    {:ok, video} = Videos.confirm_upload(video, %{"video_key" => "videos/#{video.id}/source.mp4", "duration_seconds" => 30})
    video
  end

  test "calculate_streak counts consecutive UTC days" do
    user = user()

    Enum.each(0..2, fn offset ->
      v = video("Day #{offset}")
      dt = DateTime.utc_now() |> DateTime.add(-offset * 86_400, :second) |> DateTime.truncate(:microsecond)

      %WatchProgress{}
      |> WatchProgress.changeset(%{user_id: user.id, video_id: v.id, seconds_watched: 10, last_watched_at: dt})
      |> Repo.insert!()
    end)

    assert Dashboard.calculate_streak(user.id) == 3
  end

  test "calculate_streak stops at a gap" do
    user = user()

    for offset <- [0, 2] do
      v = video("Gap #{offset}")
      dt = DateTime.utc_now() |> DateTime.add(-offset * 86_400, :second) |> DateTime.truncate(:microsecond)

      %WatchProgress{}
      |> WatchProgress.changeset(%{user_id: user.id, video_id: v.id, seconds_watched: 10, last_watched_at: dt})
      |> Repo.insert!()
    end

    assert Dashboard.calculate_streak(user.id) == 1
  end
end
