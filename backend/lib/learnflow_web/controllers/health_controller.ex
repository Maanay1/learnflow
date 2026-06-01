defmodule LearnflowWeb.HealthController do
  use LearnflowWeb, :controller

  alias Ecto.Adapters.SQL
  alias Learnflow.{Repo, Storage}

  def show(conn, _params) do
    case SQL.query(Repo, "select 1", []) do
      {:ok, _} ->
        json(conn, %{status: "ok", ok: true, version: version(), db: "ok", storage: storage_status()})

      {:error, _reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "error", ok: false, version: version(), db: "error"})
    end
  end

  defp storage_status do
    case Storage.validate_configuration() do
      :ok -> "configured"
      {:error, _reason} -> "missing"
    end
  end

  defp version, do: System.get_env("GIT_SHA", "local")
end
