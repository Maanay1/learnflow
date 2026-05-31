defmodule Learnflow.Accounts do
  @moduledoc """
  Accounts, authentication, sessions, and user profile operations.
  """

  import Ecto.Query
  alias Learnflow.Accounts.{Session, User}
  alias Learnflow.Repo

  @session_ttl_seconds 30 * 24 * 60 * 60
  @lockout_threshold 5
  @lockout_seconds 15 * 60

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_google_user(%{email: email, google_id: google_id} = attrs) do
    normalized_email = email |> to_string() |> String.trim() |> String.downcase()

    case Repo.get_by(User, email: normalized_email) do
      nil ->
        create_google_user(Map.put(attrs, :email, normalized_email))

      user ->
        user
        |> User.google_changeset(%{
          email: normalized_email,
          username: user.username,
          display_name: attrs[:display_name] || user.display_name,
          avatar_url: attrs[:avatar_url] || user.avatar_url,
          google_id: google_id,
          password_hash: user.password_hash,
          is_verified: true
        })
        |> Repo.update()
    end
  end

  def authenticate_user(email, password) do
    normalized_email = email |> to_string() |> String.downcase()
    user = Repo.get_by(User, email: normalized_email)

    cond do
      is_nil(user) ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      account_locked?(user) ->
        {:error, :account_locked, user.locked_until}

      Argon2.verify_pass(to_string(password), user.password_hash) ->
        reset_failed_logins(user)

      true ->
        user
        |> record_failed_login()
        |> case do
          {:ok, locked_user} when not is_nil(locked_user.locked_until) ->
            {:error, :account_locked, locked_user.locked_until}

          _ ->
            {:error, :invalid_credentials}
        end
    end
  end

  def create_session(%User{} = user, ip_address, user_agent) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    token_hash = hash_token(token)
    expires_at = utc_now() |> DateTime.add(@session_ttl_seconds, :second)

    attrs = %{
      user_id: user.id,
      token_hash: token_hash,
      ip_address: scrub_ip(ip_address),
      user_agent: user_agent,
      expires_at: expires_at
    }

    with {:ok, session} <- %Session{} |> Session.changeset(attrs) |> Repo.insert() do
      {:ok, token, session}
    end
  end

  def get_user_by_session_token(nil), do: nil
  def get_user_by_session_token(""), do: nil

  def get_user_by_session_token(token) do
    case get_session_by_token(token) do
      nil -> nil
      %Session{user: user} -> user
    end
  end

  def get_session_by_token(nil), do: nil
  def get_session_by_token(""), do: nil

  def get_session_by_token(token) do
    now = utc_now()

    Session
    |> where([s], s.token_hash == ^hash_token(token) and s.expires_at > ^now)
    |> preload(:user)
    |> Repo.one()
  end

  def logout(session_id) do
    case Repo.get(Session, session_id) do
      nil -> {:ok, nil}
      session -> Repo.delete(session)
    end
  end

  def logout_session_token(token) when token in [nil, ""], do: {:ok, nil}

  def logout_session_token(token) do
    token_hash = hash_token(token)

    {_, _} =
      Repo.delete_all(
        from s in Session,
          where: s.token_hash == ^token_hash
      )

    {:ok, nil}
  end

  def update_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(Map.take(attrs, ["display_name", "bio", :display_name, :bio]))
    |> Repo.update()
  end

  def update_avatar(%User{} = user, avatar_key) do
    user
    |> User.avatar_changeset(%{avatar_key: avatar_key})
    |> Repo.update()
  end

  def change_password(%User{} = user, current_password, new_password) do
    if Argon2.verify_pass(to_string(current_password), user.password_hash) do
      changeset = User.password_changeset(user, %{password: new_password})

      Repo.transaction(fn ->
        updated_user = Repo.update!(changeset)
        Repo.delete_all(from s in Session, where: s.user_id == ^user.id)
        updated_user
      end)
    else
      Argon2.no_user_verify()
      {:error, :invalid_credentials}
    end
  end

  def delete_account(%User{} = user) do
    Repo.transaction(fn ->
      Repo.delete_all(from s in Session, where: s.user_id == ^user.id)

      user
      |> User.delete_account_changeset()
      |> Repo.update!()
    end)
  end

  def request_password_reset(_email), do: :ok

  def get_public_user(username), do: Repo.get_by(User, username: username)

  def export_user_data(%User{} = user) do
    comments = Repo.all(from c in Learnflow.Social.Comment, where: c.user_id == ^user.id)
    progress = Repo.all(from p in Learnflow.Videos.WatchProgress, where: p.user_id == ^user.id)
    videos = Repo.all(from v in Learnflow.Videos.Video, where: v.creator_id == ^user.id)
    %{user: public_user(user), videos: videos, comments: comments, watch_history: progress}
  end

  def public_user(nil), do: nil

  def public_user(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar_key: user.avatar_key,
      avatar_url: user.avatar_url,
      bio: user.bio,
      is_creator: user.is_creator,
      is_verified: user.is_verified,
      stripe_onboarding_complete: user.stripe_onboarding_complete,
      payout_email: user.payout_email,
      socket_token: Phoenix.Token.sign(LearnflowWeb.Endpoint, "user socket", user.id)
    }
  end

  def hash_token(token), do: :crypto.hash(:sha256, token) |> Base.encode16(case: :upper)

  defp create_google_user(attrs) do
    username = generate_unique_username(attrs.email)

    %User{}
    |> User.google_changeset(%{
      email: attrs.email,
      username: username,
      display_name: attrs[:display_name],
      avatar_url: attrs[:avatar_url],
      google_id: attrs.google_id,
      password_hash: Argon2.hash_pwd_salt(generate_random_password()),
      is_verified: true
    })
    |> Repo.insert()
  end

  defp generate_unique_username(email) do
    base =
      email
      |> String.split("@")
      |> List.first()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]/, "_")
      |> String.trim("_")
      |> String.slice(0, 20)
      |> case do
        "" -> "user"
        value -> value
      end

    Stream.repeatedly(fn -> "#{base}_#{:rand.uniform(999_999)}" end)
    |> Enum.find(fn username -> is_nil(Repo.get_by(User, username: username)) end)
  end

  defp generate_random_password, do: :crypto.strong_rand_bytes(32) |> Base.encode64()

  defp account_locked?(%User{locked_until: nil}), do: false
  defp account_locked?(%User{locked_until: locked_until}), do: DateTime.compare(locked_until, utc_now()) == :gt

  defp reset_failed_logins(user) do
    user
    |> Ecto.Changeset.change(failed_login_attempts: 0, locked_until: nil)
    |> Repo.update()
  end

  defp record_failed_login(user) do
    attempts = user.failed_login_attempts + 1

    locked_until =
      if attempts >= @lockout_threshold do
        utc_now() |> DateTime.add(@lockout_seconds, :second)
      end

    user
    |> Ecto.Changeset.change(failed_login_attempts: attempts, locked_until: locked_until)
    |> Repo.update()
  end

  defp scrub_ip({a, b, c, d}), do: Enum.join([a, b, c, d], ".")
  defp scrub_ip(ip_address), do: ip_address |> to_string() |> String.slice(0, 255)

  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)
end
