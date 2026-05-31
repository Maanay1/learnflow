defmodule LearnflowWeb.VideoControllerTest do
  use LearnflowWeb.ConnCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Videos

  defp register_user(attrs) do
    unique = System.unique_integer([:positive])

    base = %{
      "username" => "user_#{unique}",
      "email" => "user#{unique}@example.com",
      "password" => "learn1234"
    }

    {:ok, user} = Accounts.register_user(Map.merge(base, attrs))
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

  defp active_video(creator, attrs \\ %{}) do
    {:ok, video} =
      Videos.create_video(
        creator,
        Map.merge(
          %{
            "title" => "Cursor Lesson #{System.unique_integer([:positive])}",
            "difficulty" => "beginner",
            "language" => "ru"
          },
          attrs
        )
      )

    {:ok, video} =
      Videos.confirm_upload(video, %{
        "video_key" => "videos/#{video.id}/source.mp4",
        "thumbnail_key" => "thumbnails/#{video.id}/thumb.jpg",
        "duration_seconds" => 120
      })

    video
  end

  test "creator can create video, request signed upload URLs, confirm upload, and add chapters" do
    creator = register_user(%{"is_creator" => true})

    conn =
      creator
      |> auth_conn()
      |> post("/api/videos", %{"title" => "Phoenix Video System", "difficulty" => "intermediate", "language" => "ru"})

    assert %{"video" => %{"id" => id, "status" => "pending", "slug" => slug}} = json_response(conn, 201)
    assert is_binary(slug)

    conn =
      creator
      |> auth_conn()
      |> post("/api/videos/#{id}/upload-url", %{"content_type" => "video/mp4", "file_size_bytes" => 100_000})

    assert %{"upload_url" => upload_url, "key" => "videos/" <> _} = json_response(conn, 200)
    assert upload_url =~ "learnflow-videos"

    conn =
      creator
      |> auth_conn()
      |> post("/api/videos/#{id}/thumbnail-url", %{"content_type" => "image/jpeg"})

    assert %{"upload_url" => thumbnail_url, "key" => "thumbnails/" <> _} = json_response(conn, 200)
    assert thumbnail_url =~ "learnflow-thumbnails"

    conn =
      creator
      |> auth_conn()
      |> post("/api/videos/#{id}/confirm", %{
        "video_key" => "videos/#{id}/source.mp4",
        "thumbnail_key" => "thumbnails/#{id}/thumb.jpg",
        "duration_seconds" => 300
      })

    assert %{"video" => %{"status" => "active", "duration_seconds" => 300}} = json_response(conn, 200)

    conn =
      creator
      |> auth_conn()
      |> post("/api/videos/#{id}/chapters", %{
        "chapters" => [
          %{"title" => "Intro", "start_seconds" => 0, "position" => 0},
          %{"title" => "Practice", "start_seconds" => 120, "position" => 1}
        ]
      })

    assert %{"chapters" => chapters} = json_response(conn, 200)
    assert length(chapters) == 2
  end

  test "feed returns active videos with cursor pagination and signed thumbnail URLs" do
    creator = register_user(%{"is_creator" => true})
    first = active_video(creator, %{"title" => "Feed First"})
    second = active_video(creator, %{"title" => "Feed Second"})

    conn = get(build_conn(), "/api/feed", %{"limit" => 1})
    assert %{"items" => [item], "next_cursor" => cursor} = json_response(conn, 200)
    assert cursor
    assert item["thumbnail_url"] =~ "learnflow-thumbnails"

    conn = get(build_conn(), "/api/feed", %{"limit" => 1, "cursor" => cursor})
    assert %{"items" => [next_item]} = json_response(conn, 200)
    assert item["id"] != next_item["id"]
    assert Enum.sort([first.id, second.id]) == Enum.sort([item["id"], next_item["id"]])
  end

  test "viewer can request signed view URL and track progress" do
    creator = register_user(%{"is_creator" => true})
    learner = register_user(%{})
    video = active_video(creator)

    conn =
      learner
      |> auth_conn()
      |> get("/api/videos/#{video.id}/view-url")

    assert %{"view_url" => url} = json_response(conn, 200)
    assert url =~ "learnflow-videos"

    conn =
      learner
      |> auth_conn()
      |> post("/api/videos/#{video.id}/progress", %{"seconds_watched" => 42})

    assert %{"progress" => %{"seconds_watched" => 42, "completed" => false}} = json_response(conn, 200)

    conn =
      learner
      |> auth_conn()
      |> post("/api/videos/#{video.id}/progress", %{"seconds_watched" => 999})

    assert %{"progress" => %{"seconds_watched" => 120, "completed" => true}} = json_response(conn, 200)

    conn =
      learner
      |> auth_conn()
      |> get("/api/videos/#{video.id}/progress")

    assert %{"progress" => %{"seconds_watched" => 120, "completed" => true}} = json_response(conn, 200)
  end
end
