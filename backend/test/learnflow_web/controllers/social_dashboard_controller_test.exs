defmodule LearnflowWeb.SocialDashboardControllerTest do
  use LearnflowWeb.ConnCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Repo
  alias Learnflow.Social
  alias Learnflow.Videos

  defp user(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      Accounts.register_user(
        Map.merge(
          %{
            "username" => "social_api_#{n}",
            "email" => "social_api_#{n}@example.com",
            "password" => "learn1234"
          },
          attrs
        )
      )

    user
  end

  defp auth_conn(user) do
    {:ok, token, _session} = Accounts.create_session(user, "127.0.0.1", "ExUnit")
    csrf = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    build_conn()
    |> put_req_cookie("session_token", token)
    |> put_req_cookie("csrf_token", csrf)
    |> put_req_header("x-csrf-token", csrf)
  end

  defp active_video do
    creator = user(%{"is_creator" => true})
    {:ok, video} = Videos.create_video(creator, %{"title" => "Social API", "difficulty" => "beginner", "language" => "ru"})

    {:ok, video} =
      Videos.confirm_upload(video, %{
        "video_key" => "videos/#{video.id}/source.mp4",
        "thumbnail_key" => "thumbnails/#{video.id}/thumb.jpg",
        "duration_seconds" => 100
      })

    {creator, video}
  end

  test "like, unlike, save, unsave, follow, and unfollow endpoints work" do
    learner = user()
    {creator, video} = active_video()

    conn = learner |> auth_conn() |> post("/api/videos/#{video.id}/like")
    assert %{"ok" => true, "status" => "liked", "like_count" => 1} = json_response(conn, 200)

    conn = learner |> auth_conn() |> delete("/api/videos/#{video.id}/like")
    assert %{"ok" => true, "status" => "unliked", "like_count" => 0} = json_response(conn, 200)

    conn = learner |> auth_conn() |> post("/api/videos/#{video.id}/save")
    assert %{"ok" => true, "status" => "saved"} = json_response(conn, 200)
    assert Social.is_saved?(learner.id, video.id)

    conn = learner |> auth_conn() |> delete("/api/videos/#{video.id}/save")
    assert %{"ok" => true, "status" => "unsaved"} = json_response(conn, 200)

    conn = learner |> auth_conn() |> post("/api/users/#{creator.id}/follow")
    assert %{"ok" => true, "status" => "followed"} = json_response(conn, 200)
    assert Social.is_following?(learner.id, creator.id)

    conn = learner |> auth_conn() |> delete("/api/users/#{creator.id}/follow")
    assert %{"ok" => true, "status" => "unfollowed"} = json_response(conn, 200)
  end

  test "comments endpoint creates, lists with replies, and soft deletes" do
    learner = user()
    {_creator, video} = active_video()

    conn = learner |> auth_conn() |> post("/api/videos/#{video.id}/comments", %{"body" => "Great lesson"})
    assert %{"comment" => %{"id" => parent_id, "body" => "Great lesson"}} = json_response(conn, 201)

    conn =
      learner
      |> auth_conn()
      |> post("/api/videos/#{video.id}/comments", %{"body" => "Reply", "parent_id" => parent_id})

    assert %{"comment" => %{"parent_id" => ^parent_id}} = json_response(conn, 201)

    conn = learner |> auth_conn() |> get("/api/videos/#{video.id}/comments")
    assert %{"comments" => [comment], "next_cursor" => nil} = json_response(conn, 200)
    assert comment["id"] == parent_id
    assert [%{"body" => "Reply"}] = comment["replies"]

    conn = learner |> auth_conn() |> delete("/api/comments/#{parent_id}")
    assert %{"comment" => %{"body" => "[deleted]", "is_deleted" => true}} = json_response(conn, 200)
  end

  test "dashboard stats, history, saved videos, delete history, and export work" do
    learner = user()
    {_creator, video} = active_video()

    {:ok, _} = Videos.update_watch_progress(learner.id, video.id, 95)
    {:ok, _} = Social.save_video(learner.id, video.id)
    {:ok, _} = Social.like_video(learner.id, video.id)

    conn = learner |> auth_conn() |> get("/api/dashboard/stats")
    assert %{"total_watched" => 1, "total_completed" => 1} = json_response(conn, 200)

    conn = learner |> auth_conn() |> get("/api/dashboard/history")
    assert %{"items" => [%{"video" => %{"id" => video_id, "thumbnail_url" => thumb}}]} = json_response(conn, 200)
    assert video_id == video.id
    assert thumb =~ "learnflow-thumbnails"

    conn = learner |> auth_conn() |> get("/api/dashboard/saved")
    assert %{"items" => [%{"video" => %{"id" => ^video_id}}]} = json_response(conn, 200)

    conn = learner |> auth_conn() |> get("/api/dashboard/export")
    assert %{"likes" => [_], "saves" => [_], "watch_history" => [_]} = json_response(conn, 200)

    conn = learner |> auth_conn() |> delete("/api/dashboard/history/#{video.id}")
    assert %{"ok" => true, "status" => "deleted"} = json_response(conn, 200)
    refute Repo.get_by(Learnflow.Videos.WatchProgress, user_id: learner.id, video_id: video.id)
  end
end
