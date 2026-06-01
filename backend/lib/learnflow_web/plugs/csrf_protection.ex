defmodule LearnflowWeb.Plugs.CSRFProtection do
  import Plug.Conn
  import Phoenix.Controller

  @unsafe ~w(POST PUT PATCH DELETE)
  @csrf_exempt_auth_paths ~w(/api/auth/register /api/auth/login)
  def init(opts), do: opts

  def call(%{request_path: path} = conn, _opts) when path in @csrf_exempt_auth_paths do
    ensure_csrf_cookie(conn)
  end

  def call(%{method: method} = conn, _opts) when method in @unsafe do
    token = get_req_header(conn, "x-csrf-token") |> List.first()
    cookie = conn |> fetch_cookies() |> Map.get(:req_cookies) |> Map.get("csrf_token")

    if token && cookie && Plug.Crypto.secure_compare(token, cookie) do
      conn
    else
      conn |> put_status(:forbidden) |> json(%{error: "invalid_csrf"}) |> halt()
    end
  end

  def call(conn, _opts) do
    ensure_csrf_cookie(conn)
  end

  defp ensure_csrf_cookie(conn) do
    conn = fetch_cookies(conn)

    if Map.has_key?(conn.req_cookies, "csrf_token") do
      conn
    else
      token = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

      put_resp_cookie(conn, "csrf_token", token,
        http_only: false,
        same_site: cookie_same_site(),
        secure: cookie_secure?(),
        max_age: 86_400
      )
    end
  end

  defp cookie_secure? do
    System.get_env("COOKIE_SECURE", "false") == "true"
  end

  defp cookie_same_site, do: if(cookie_secure?(), do: "None", else: "Lax")
end
