defmodule LearnflowWeb.HealthController do
  use LearnflowWeb, :controller

  alias Ecto.Adapters.SQL
  alias Learnflow.Repo

  def show(conn, _params) do
    case SQL.query(Repo, "select 1", []) do
      {:ok, _} ->
        json(conn, %{status: "ok", ok: true, version: version(), db: "ok"})

      {:error, _reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "error", ok: false, version: version(), db: "error"})
    end
  end

  defp version, do: System.get_env("GIT_SHA", "local")
end
