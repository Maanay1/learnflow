defmodule LearnflowWeb.AuthController do
  use LearnflowWeb, :controller
  alias Learnflow.Accounts
  require Logger

  @session_cookie "session_token"
  @session_max_age 30 * 24 * 60 * 60

  def register(conn, params) do
    with {:ok, user} <- Accounts.register_user(params),
         {:ok, token, _session} <- Accounts.create_session(user, client_ip(conn), user_agent(conn)) do
      conn
      |> put_status(:created)
      |> put_session_cookie(token)
      |> json(%{user: Accounts.public_user(user)})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(changeset_error(changeset))
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _session} = Accounts.create_session(user, client_ip(conn), user_agent(conn))

        conn
        |> put_session_cookie(token)
        |> json(%{user: Accounts.public_user(user)})

      {:error, :account_locked, locked_until} ->
        conn
        |> put_status(:locked)
        |> json(%{error: "account_locked", locked_until: DateTime.to_iso8601(locked_until)})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_credentials"})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "invalid_credentials"})
  end

  def logout(conn, _params) do
    case conn.assigns[:current_session] do
      nil -> Accounts.logout_session_token(conn.req_cookies[@session_cookie])
      session -> Accounts.logout(session.id)
    end

    conn
    |> delete_resp_cookie(@session_cookie, http_only: true, secure: cookie_secure?(), same_site: "Strict")
    |> json(%{ok: true})
  end

  def me(conn, _params), do: json(conn, %{user: Accounts.public_user(conn.assigns.current_user)})

  def google_request(conn, _params) do
    redirect(conn,
      external:
        Ueberauth.Strategy.Google.OAuth.authorize_url!(
          scope: "email profile",
          redirect_uri: google_callback_url()
        )
    )
  end

  def google_callback(conn, %{"code" => code}) do
    with {:ok, token} <- get_google_access_token(code),
         {:ok, user_info} <- get_google_user_info(token.access_token),
         {:ok, user} <- find_or_create_google_user(user_info),
         {:ok, session_token, _session} <- create_google_session(user, conn) do
      conn
      |> put_resp_cookie(@session_cookie, session_token,
        http_only: true,
        secure: cookie_secure?(),
        same_site: "Lax",
        max_age: @session_max_age
      )
      |> redirect(external: "#{frontend_url()}/feed")
    else
      {:error, reason} ->
        Logger.warning("Google OAuth callback failed: #{inspect(reason)}")
        redirect(conn, external: "#{frontend_url()}/login?error=google_auth_failed")
    end
  end

  def google_callback(conn, _params) do
    redirect(conn, external: "#{frontend_url()}/login?error=google_auth_failed")
  end

  defp put_session_cookie(conn, token) do
    put_resp_cookie(conn, @session_cookie, token,
      http_only: true,
      secure: cookie_secure?(),
      same_site: "Strict",
      max_age: @session_max_age
    )
  end

  defp cookie_secure? do
    System.get_env("COOKIE_SECURE", "false") == "true"
  end

  defp changeset_error(changeset) do
    {field, messages} =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {message, _opts} -> message end)
      |> Enum.at(0, {:base, ["invalid"]})

    %{error: List.first(messages), field: to_string(field)}
  end

  defp client_ip(conn), do: conn.remote_ip |> :inet.ntoa() |> to_string()
  defp user_agent(conn), do: conn |> get_req_header("user-agent") |> List.first()

  defp get_google_access_token(code) do
    case Ueberauth.Strategy.Google.OAuth.get_access_token(
           [code: code],
           redirect_uri: google_callback_url()
         ) do
      {:ok, token} -> {:ok, token}
      {:error, reason} -> {:error, {:token_exchange, reason}}
    end
  end

  defp get_google_user_info(access_token) do
    case Ueberauth.Strategy.Google.OAuth.get(
           %OAuth2.AccessToken{access_token: access_token},
           "https://www.googleapis.com/oauth2/v3/userinfo"
         ) do
      {:ok, %OAuth2.Response{status_code: status, body: body}}
      when status in 200..299 and is_map(body) ->
        {:ok, body}

      {:ok, %OAuth2.Response{status_code: status}} ->
        {:error, {:google_user_info, status}}

      {:error, _reason} ->
        {:error, :google_user_info_request_failed}
    end
  end

  defp find_or_create_google_user(user_info) do
    case Accounts.find_or_create_google_user(%{
           email: user_info["email"],
           display_name: user_info["name"],
           avatar_url: user_info["picture"],
           google_id: user_info["sub"]
         }) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, {:account, changeset_error(changeset)}}
    end
  end

  defp create_google_session(user, conn) do
    case Accounts.create_session(user, client_ip(conn), user_agent(conn)) do
      {:ok, token, session} -> {:ok, token, session}
      {:error, changeset} -> {:error, {:session, changeset_error(changeset)}}
    end
  end

  defp google_callback_url, do: "#{api_public_url()}/auth/google/callback"
  defp api_public_url, do: System.get_env("API_PUBLIC_URL", "http://localhost:4000") |> String.trim_trailing("/")
  defp frontend_url, do: System.get_env("FRONTEND_URL", "http://localhost:3000") |> String.trim_trailing("/")
end
