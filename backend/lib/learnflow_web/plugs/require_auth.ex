defmodule LearnflowWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias Learnflow.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    token = conn.req_cookies["session_token"]

    case Accounts.get_session_by_token(token) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized"})
        |> halt()

      session ->
        conn
        |> assign(:current_user, session.user)
        |> assign(:current_session, session)
    end
  end
end
