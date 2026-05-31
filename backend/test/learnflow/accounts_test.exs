defmodule Learnflow.AccountsTest do
  use Learnflow.DataCase, async: true

  alias Learnflow.Accounts
  alias Learnflow.Accounts.Session
  alias Learnflow.Repo

  @valid_attrs %{
    "username" => "learner_1",
    "email" => "learner@example.com",
    "password" => "learn1234"
  }

  describe "register_user/1" do
    test "creates a user with an Argon2id password hash" do
      assert {:ok, user} = Accounts.register_user(@valid_attrs)
      assert user.email == "learner@example.com"
      assert user.username == "learner_1"
      assert user.password_hash
      refute user.password_hash == @valid_attrs["password"]
      assert Argon2.verify_pass(@valid_attrs["password"], user.password_hash)
    end

    test "validates email, username, and password" do
      attrs = %{@valid_attrs | "email" => "bad", "username" => "bad-name!", "password" => "password"}

      assert {:error, changeset} = Accounts.register_user(attrs)
      errors = errors_on(changeset)
      assert errors.email
      assert errors.username
      assert errors.password
    end
  end

  describe "authenticate_user/2" do
    test "returns the user and resets failed attempts on valid credentials" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      user
      |> Ecto.Changeset.change(failed_login_attempts: 2)
      |> Repo.update!()

      assert {:ok, authed} = Accounts.authenticate_user("LEARNER@example.com", "learn1234")
      assert authed.id == user.id
      assert authed.failed_login_attempts == 0
    end

    test "returns invalid credentials and increments failed attempts" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      assert {:error, :invalid_credentials} = Accounts.authenticate_user(user.email, "wrong1234")

      updated = Repo.get!(Learnflow.Accounts.User, user.id)
      assert updated.failed_login_attempts == 1
    end

    test "locks account after 5 failed attempts" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      for _ <- 1..4 do
        assert {:error, :invalid_credentials} = Accounts.authenticate_user(user.email, "wrong1234")
      end

      assert {:error, :account_locked, locked_until} = Accounts.authenticate_user(user.email, "wrong1234")
      assert DateTime.compare(locked_until, DateTime.utc_now()) == :gt
      assert {:error, :account_locked, ^locked_until} = Accounts.authenticate_user(user.email, "learn1234")
    end
  end

  describe "sessions" do
    test "create_session/3 returns a raw token and stores only its hash" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      assert {:ok, token, session} = Accounts.create_session(user, "127.0.0.1", "ExUnit")
      assert byte_size(token) > 32
      assert session.token_hash == Accounts.hash_token(token)
      refute session.token_hash == token
      assert Accounts.get_user_by_session_token(token).id == user.id
    end

    test "expired sessions do not authenticate" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

      {:ok, _session} =
        %Session{}
        |> Session.changeset(%{
          user_id: user.id,
          token_hash: Accounts.hash_token(token),
          expires_at: DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:microsecond)
        })
        |> Repo.insert()

      assert Accounts.get_user_by_session_token(token) == nil
    end
  end
end
