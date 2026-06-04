defmodule LearnflowWeb.UserController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Analytics, Dashboard, Storage}
  alias LearnflowWeb.VideoJSON

  @avatar_types %{
    "image/jpeg" => ".jpg",
    "image/png" => ".png",
    "image/webp" => ".webp"
  }
  @max_avatar_bytes 5 * 1024 * 1024

  def show(conn, %{"username" => username}) do
    case Dashboard.public_profile(username, viewer_id(conn)) do
      nil ->
        {:error, :not_found}

      profile ->
        track_profile_view(conn, profile)
        json(conn, %{user: profile})
    end
  end

  def videos(conn, %{"username" => username} = params) do
    with user when not is_nil(user) <- Accounts.get_public_user(username) do
      {videos, next_cursor} = Dashboard.public_videos(user.id, params)
      json(conn, %{items: Enum.map(videos, &VideoJSON.video/1), next_cursor: next_cursor})
    else
      _ -> {:error, :not_found}
    end
  end

  def search(conn, params), do: json(conn, %{users: Accounts.search_users(params["q"], viewer_id(conn))})
  def username_available(conn, params), do: json(conn, %{available: Accounts.username_available?(params["username"], viewer_id(conn))})

  def followers(conn, %{"username" => username}) do
    with user when not is_nil(user) <- Accounts.get_public_user(username) do
      json(conn, %{users: Accounts.list_followers(user.id, viewer_id(conn))})
    else
      _ -> {:error, :not_found}
    end
  end

  def following(conn, %{"username" => username}) do
    with user when not is_nil(user) <- Accounts.get_public_user(username) do
      json(conn, %{users: Accounts.list_following(user.id, viewer_id(conn))})
    else
      _ -> {:error, :not_found}
    end
  end

  def update(conn, params), do: with({:ok, user} <- Accounts.update_profile(conn.assigns.current_user, params), do: json(conn, %{user: Accounts.public_user(user)}))

  def password(conn, %{"current_password" => current_password, "new_password" => new_password}) do
    case Accounts.change_password(conn.assigns.current_user, current_password, new_password) do
      {:ok, _user} -> json(conn, %{ok: true})
      {:error, :invalid_credentials} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_current_password"})
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def avatar(conn, %{"avatar" => %Plug.Upload{} = upload}) do
    with {:ok, extension} <- avatar_extension(upload.content_type),
         {:ok, %{size: size}} when size <= @max_avatar_bytes <- File.stat(upload.path),
         {:ok, body} <- File.read(upload.path),
         key = "#{conn.assigns.current_user.id}-#{Ecto.UUID.generate()}#{extension}",
         {:ok, _response} <- Storage.put_object(Storage.bucket_avatars(), key, body, upload.content_type),
         {:ok, user} <- Accounts.update_avatar(conn.assigns.current_user, key) do
      json(conn, %{user: Accounts.public_user(user)})
    else
      {:ok, %{size: _}} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "avatar_too_large"})
      {:error, :invalid_avatar_type} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_avatar_type"})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
    end
  end

  def avatar(conn, _params), do: conn |> put_status(:unprocessable_entity) |> json(%{error: "avatar_required"})

  def avatar_file(conn, %{"key" => key}) do
    with true <- String.match?(key, ~r/^[a-zA-Z0-9._-]+$/),
         {:ok, body} <- Storage.get_object(Storage.bucket_avatars(), key) do
      conn
      |> put_resp_content_type(avatar_content_type(key))
      |> put_resp_header("cache-control", "public, max-age=86400")
      |> send_resp(:ok, body)
    else
      _ -> {:error, :not_found}
    end
  end

  def delete(conn, _), do: with({:ok, _} <- Accounts.delete_account(conn.assigns.current_user), do: json(conn, %{ok: true}))

  defp viewer_id(conn) do
    case conn.assigns[:current_user] do
      nil ->
        case Accounts.get_user_by_session_token(conn.req_cookies["session_token"]) do
          nil -> nil
          user -> user.id
        end

      user ->
        user.id
    end
  end

  defp track_profile_view(conn, profile) do
    Analytics.track("profile_view", %{
      actor_id: viewer_id(conn),
      target_user_id: profile.id,
      metadata: %{username: profile.username},
      ip_address: client_ip(conn),
      user_agent: user_agent(conn)
    })
  end

  defp client_ip(conn), do: conn.remote_ip |> :inet.ntoa() |> to_string()
  defp user_agent(conn), do: conn |> get_req_header("user-agent") |> List.first()

  defp avatar_extension(content_type) do
    case Map.fetch(@avatar_types, content_type) do
      {:ok, extension} -> {:ok, extension}
      :error -> {:error, :invalid_avatar_type}
    end
  end

  defp avatar_content_type(key) do
    cond do
      String.ends_with?(key, ".png") -> "image/png"
      String.ends_with?(key, ".webp") -> "image/webp"
      true -> "image/jpeg"
    end
  end
end
