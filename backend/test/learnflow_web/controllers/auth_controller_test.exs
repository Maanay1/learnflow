defmodule LearnflowWeb.AuthControllerTest do
  use LearnflowWeb.ConnCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Accounts.Session
  alias Learnflow.Repo

  @valid_attrs %{
    "username" => "learner_api",
    "email" => "learner_api@example.com",
    "password" => "learn1234"
  }

  test "POST /api/auth/register creates a user and sets an http-only session cookie", %{
    conn: conn
  } do
    conn = post(conn, "/api/auth/register", @valid_attrs)

    assert %{"user" => %{"username" => "learner_api"}} = json_response(conn, 201)

    cookie =
      get_resp_header(conn, "set-cookie") |> Enum.find(&String.contains?(&1, "session_token="))

    assert cookie
    assert cookie =~ "session_token="
    assert cookie =~ "HttpOnly"
    assert cookie =~ "SameSite=Lax"
  end

  test "POST /api/auth/login authenticates and sets a session cookie", %{conn: conn} do
    {:ok, _user} = Accounts.register_user(@valid_attrs)

    conn =
      post(conn, "/api/auth/login", %{
        "email" => @valid_attrs["email"],
        "password" => @valid_attrs["password"]
      })

    assert %{"user" => %{"username" => "learner_api"}} = json_response(conn, 200)

    assert get_resp_header(conn, "set-cookie")
           |> Enum.any?(&String.contains?(&1, "session_token="))
  end

  test "POST /api/auth/login returns locked after 5 failed attempts", %{conn: conn} do
    {:ok, _user} = Accounts.register_user(@valid_attrs)

    for _ <- 1..4 do
      conn =
        post(build_conn(), "/api/auth/login", %{
          "email" => @valid_attrs["email"],
          "password" => "wrong1234"
        })

      assert json_response(conn, 401)["error"] == "invalid_credentials"
    end

    conn =
      post(conn, "/api/auth/login", %{"email" => @valid_attrs["email"], "password" => "wrong1234"})

    assert %{"error" => "account_locked", "locked_until" => _} = json_response(conn, 423)
  end

  test "GET /api/auth/me requires a valid session", %{conn: conn} do
    assert %{"error" => "unauthorized"} = conn |> get("/api/auth/me") |> json_response(401)

    {:ok, user} = Accounts.register_user(@valid_attrs)
    {:ok, token, _session} = Accounts.create_session(user, "127.0.0.1", "ExUnit")

    conn =
      conn
      |> recycle()
      |> put_req_cookie("session_token", token)
      |> get("/api/auth/me")

    assert %{"user" => %{"username" => "learner_api"}} = json_response(conn, 200)
  end

  test "DELETE /api/auth/logout deletes the session and clears the cookie", %{conn: conn} do
    {:ok, user} = Accounts.register_user(@valid_attrs)
    {:ok, token, session} = Accounts.create_session(user, "127.0.0.1", "ExUnit")

    conn =
      conn
      |> put_req_cookie("session_token", token)
      |> put_csrf()
      |> delete("/api/auth/logout")

    assert %{"ok" => true} = json_response(conn, 200)
    assert Repo.get(Session, session.id) == nil

    assert get_resp_header(conn, "set-cookie")
           |> Enum.any?(&String.contains?(&1, "session_token=;"))
  end

  test "GET /auth/google/session rotates the bridge ticket and sets a session cookie", %{
    conn: conn
  } do
    {:ok, user} = Accounts.register_user(@valid_attrs)
    {:ok, ticket, _session} = Accounts.create_session(user, "127.0.0.1", "ExUnit")

    conn = get(conn, "/auth/google/session?ticket=#{URI.encode_www_form(ticket)}")

    assert redirected_to(conn) == "http://localhost:3000/jq"
    session_token = conn.resp_cookies["session_token"].value
    refute session_token == ticket
    assert Accounts.get_user_by_session_token(ticket) == nil
    assert Accounts.get_user_by_session_token(session_token).id == user.id
  end

  test "GET /auth/google redirects with a signed state token", %{conn: conn} do
    conn = get(conn, "/auth/google")
    query = conn |> redirected_to() |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()

    assert query["redirect_uri"] == "http://localhost:4000/auth/google/callback"

    assert {:ok, _nonce} =
             Phoenix.Token.verify(LearnflowWeb.Endpoint, "google oauth state", query["state"],
               max_age: 600
             )
  end

  test "GET /auth/google/callback rejects a callback without state", %{conn: conn} do
    conn = get(conn, "/auth/google/callback?code=unused")

    assert redirected_to(conn) == "http://localhost:3000/login?error=google_auth_failed"
  end

  defp put_csrf(conn) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    conn
    |> put_req_cookie("csrf_token", token)
    |> put_req_header("x-csrf-token", token)
  end
end
