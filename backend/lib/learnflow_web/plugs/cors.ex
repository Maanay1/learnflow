defmodule LearnflowWeb.Plugs.CORS do
  import Plug.Conn

  @allowed_methods "GET,POST,PUT,PATCH,DELETE,OPTIONS"
  @allowed_headers "content-type,x-csrf-token,authorization"

  def init(opts), do: opts

  def call(%{method: "OPTIONS"} = conn, _opts) do
    conn
    |> put_cors_headers()
    |> send_resp(:no_content, "")
    |> halt()
  end

  def call(conn, _opts), do: put_cors_headers(conn)

  defp put_cors_headers(conn) do
    origin = conn |> get_req_header("origin") |> List.first()

    conn
    |> maybe_put_origin(origin)
    |> put_resp_header("access-control-allow-methods", @allowed_methods)
    |> put_resp_header("access-control-allow-headers", @allowed_headers)
    |> put_resp_header("access-control-allow-credentials", "true")
    |> put_resp_header("access-control-max-age", "86400")
    |> put_resp_header("vary", "origin")
  end

  defp maybe_put_origin(conn, origin) when origin in ["http://localhost:3000", "http://127.0.0.1:3000"] do
    put_resp_header(conn, "access-control-allow-origin", origin)
  end

  defp maybe_put_origin(conn, _origin), do: conn
end
