defmodule LearnflowWeb.Plugs.SecurityHeaders do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("content-security-policy", "default-src 'self'")
    |> put_resp_header("x-frame-options", "DENY")
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
    |> put_resp_header("permissions-policy", "camera=(), microphone=(), geolocation=()")
    |> maybe_noindex()
  end

  defp maybe_noindex(%{request_path: path} = conn) do
    if String.starts_with?(path, "/api/auth") do
      put_resp_header(conn, "x-robots-tag", "noindex")
    else
      conn
    end
  end
end
