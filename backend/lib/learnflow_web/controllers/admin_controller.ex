defmodule LearnflowWeb.AdminController do
  use LearnflowWeb, :controller
  alias Learnflow.Analytics

  def analytics(conn, _params) do
    if Analytics.admin?(conn.assigns.current_user) do
      json(conn, Analytics.summary())
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "admin_only"})
    end
  end
end
