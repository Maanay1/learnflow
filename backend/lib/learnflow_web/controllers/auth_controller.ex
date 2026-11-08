defmodule LearnflowWeb.AuthController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Analytics}
  require Logger

  @session_cookie "session_token"
  @session_max_age 30 * 24 * 60 * 60
  @google_state_salt "google oauth state"
  @google_state_max_age 10 * 60
  @app_callback "jarq://auth"

  def register(conn, params) do
    with {:ok, user} <- Accounts.register_user(params),
         {:ok, token, _session} <-
           Accounts.create_session(user, client_ip(conn), user_agent(conn)) do
      track_auth_event("register", user, conn)

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
        track_auth_event("login", user, conn)

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
    |> delete_resp_cookie(@session_cookie,
      http_only: true,
      secure: cookie_secure?(),
      same_site: cookie_same_site()
    )
    |> json(%{ok: true})
  end

  def me(conn, _params), do: json(conn, %{user: Accounts.public_user(conn.assigns.current_user)})

  # `?app=1` is used by the Android/iOS apps: Google forbids sign-in inside
  # embedded WebViews, so the apps open this URL in the system browser
  # (Custom Tabs / ASWebAuthenticationSession) and receive the result through
  # the `jarq://auth` deep link instead of a web redirect.
  def google_request(conn, params) do
    state = google_state(app_platform(params["app"]))

    url =
      Ueberauth.Strategy.Google.OAuth.authorize_url!(
        scope: "email profile",
        redirect_uri: google_callback_url(),
        state: state
      )

    redirect(conn, external: url)
  end

  def google_callback(conn, %{"code" => code, "state" => state}) do
    with {:ok, app} <- verify_google_state(state),
         {:ok, token} <- get_google_access_token(code),
         {:ok, user_info} <- get_google_user_info(token.access_token),
         {:ok, user} <- find_or_create_google_user(user_info),
         {:ok, session_token, _session} <- create_google_session(user, conn) do
      track_auth_event("google_login", user, conn)

      case app do
        nil -> redirect(conn, external: google_session_url(session_token))
        platform -> return_to_app(conn, platform, "ticket=#{URI.encode_www_form(session_token)}")
      end
    else
      {:error, reason} ->
        Logger.warning("Google OAuth callback failed: #{inspect(reason)}")
        google_failure(conn, state, failure_code(reason))
    end
  end

  def google_callback(conn, params) do
    code =
      cond do
        params["error"] -> "google_#{params["error"]}"
        is_nil(params["state"]) -> "no_state"
        true -> "no_code"
      end
    google_failure(conn, params["state"], code)
  end

  # `code` is a short, non-secret hint shown to the user so failures can be diagnosed.
  defp google_failure(conn, state, code) do
    query = "error=google_auth_failed&reason=#{URI.encode_www_form(code)}"

    case state_platform(state) do
      nil -> redirect(conn, external: "#{frontend_url()}/login?#{query}")
      platform -> app_page(conn, app_link(platform, query), "Не удалось войти через Google", "Код ошибки: #{code}", false)
    end
  end

  defp failure_code(:invalid_google_state), do: "state"
  defp failure_code({:token_exchange, _}), do: "token"
  defp failure_code({:google_user_info, status}), do: "userinfo_#{status}"
  defp failure_code(:google_user_info_request_failed), do: "userinfo"
  defp failure_code({:account, %{field: field}}), do: "account_#{field}"
  defp failure_code({:session, _}), do: "session"
  defp failure_code(_), do: "unknown"

  def google_session(conn, %{"ticket" => ticket}) do
    case Accounts.rotate_session_token(ticket, client_ip(conn), user_agent(conn)) do
      {:ok, session_token} ->
        conn
        |> put_session_cookie(session_token)
        |> redirect(external: "#{frontend_url()}/feed")

      {:error, reason} ->
        Logger.warning("Google OAuth session bridge failed: #{inspect(reason)}")
        redirect(conn, external: "#{frontend_url()}/login?error=google_auth_failed&reason=ticket")
    end
  end

  def google_session(conn, _params) do
    redirect(conn, external: "#{frontend_url()}/login?error=google_auth_failed&reason=no_ticket")
  end

  defp put_session_cookie(conn, token) do
    put_resp_cookie(conn, @session_cookie, token,
      http_only: true,
      secure: cookie_secure?(),
      same_site: cookie_same_site(),
      max_age: @session_max_age
    )
  end

  defp cookie_secure? do
    System.get_env("COOKIE_SECURE", "false") == "true"
  end

  defp cookie_same_site, do: if(cookie_secure?(), do: "None", else: "Lax")

  defp changeset_error(changeset) do
    {field, messages} =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {message, _opts} -> message end)
      |> Enum.at(0, {:base, ["invalid"]})

    %{error: List.first(messages), field: to_string(field)}
  end

  defp client_ip(conn), do: conn.remote_ip |> :inet.ntoa() |> to_string()
  defp user_agent(conn), do: conn |> get_req_header("user-agent") |> List.first()

  defp track_auth_event(event_type, user, conn) do
    Analytics.track(event_type, %{
      actor_id: user.id,
      ip_address: client_ip(conn),
      user_agent: user_agent(conn)
    })
  end

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

  defp google_callback_url, do: "#{backend_url()}/auth/google/callback"

  defp google_session_url(token),
    do: "#{frontend_url()}/auth/google/session?ticket=#{URI.encode_www_form(token)}"

  # nil = website, "ios" (ASWebAuthenticationSession), "android" (Custom Tab).
  defp app_platform("android"), do: "android"
  defp app_platform(value) when value in ["1", "true", "ios"], do: "ios"
  defp app_platform(_value), do: nil

  defp google_state(platform) do
    nonce = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    payload = if platform, do: %{"nonce" => nonce, "app" => platform}, else: nonce
    Phoenix.Token.sign(LearnflowWeb.Endpoint, @google_state_salt, payload)
  end

  # Returns {:ok, platform} where platform is nil for the website.
  defp verify_google_state(state) do
    case Phoenix.Token.verify(LearnflowWeb.Endpoint, @google_state_salt, state,
           max_age: @google_state_max_age
         ) do
      {:ok, %{"app" => true}} -> {:ok, "ios"}
      {:ok, %{"app" => platform}} when platform in ["ios", "android"] -> {:ok, platform}
      {:ok, _nonce} -> {:ok, nil}
      {:error, _reason} -> {:error, :invalid_google_state}
    end
  end

  defp state_platform(state) when is_binary(state) do
    case verify_google_state(state) do
      {:ok, platform} -> platform
      _ -> nil
    end
  end

  defp state_platform(_state), do: nil

  # iOS: ASWebAuthenticationSession catches the jarq:// redirect itself.
  defp return_to_app(conn, "ios", query), do: redirect(conn, external: app_link("ios", query))

  # Android: Chrome may silently block an automatic redirect to a custom scheme,
  # so show a page that opens the app through an intent:// link (auto + button).
  defp return_to_app(conn, "android", query),
    do: app_page(conn, app_link("android", query), "Готово", "Возвращаемся в приложение JARQ…", true)

  defp app_link("ios", query), do: "#{@app_callback}?#{query}"
  defp app_link("android", query), do: "intent://auth?#{query}#Intent;scheme=jarq;end"

  # Small page shown inside the sign-in browser. Failures stay visible (with a
  # diagnostic code) instead of silently bouncing back to the app.
  defp app_page(conn, link, title, text, auto_open?) do
    escaped = Plug.HTML.html_escape(link)
    script = if auto_open?, do: "<script>location.replace(#{Jason.encode!(link)});</script>", else: ""

    html = """
    <!doctype html><html lang="ru"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>JARQ</title>
    <style>body{margin:0;display:grid;min-height:100vh;place-items:center;background:#09090b;color:#fafafa;font:16px system-ui,sans-serif;text-align:center;padding:24px}
    a{display:inline-block;margin-top:20px;border-radius:14px;background:#f4b740;padding:15px 26px;color:#0a0a0a;font-weight:800;text-decoration:none}
    p{color:#a1a1aa}</style></head>
    <body><main><h1>#{Plug.HTML.html_escape(title)}</h1><p>#{Plug.HTML.html_escape(text)}</p>
    <a id="open" href="#{escaped}">Открыть JARQ</a></main>
    #{script}</body></html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  defp backend_url,
    do: System.get_env("BACKEND_URL", "http://localhost:4000") |> String.trim_trailing("/")

  defp frontend_url,
    do: System.get_env("FRONTEND_URL", "http://localhost:3000") |> String.trim_trailing("/")
end
