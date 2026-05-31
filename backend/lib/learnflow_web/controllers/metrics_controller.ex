defmodule LearnflowWeb.MetricsController do
  use LearnflowWeb, :controller

  alias Ecto.Adapters.SQL
  alias Learnflow.Repo

  def index(conn, _params) do
    body = """
    # HELP learnflow_up Application health status.
    # TYPE learnflow_up gauge
    learnflow_up 1
    # HELP learnflow_db_up Database health status.
    # TYPE learnflow_db_up gauge
    learnflow_db_up #{db_up()}
    # HELP learnflow_beam_memory_bytes BEAM memory usage in bytes.
    # TYPE learnflow_beam_memory_bytes gauge
    learnflow_beam_memory_bytes #{:erlang.memory(:total)}
    # HELP learnflow_beam_process_count BEAM process count.
    # TYPE learnflow_beam_process_count gauge
    learnflow_beam_process_count #{:erlang.system_info(:process_count)}
    """

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, body)
  end

  defp db_up do
    case SQL.query(Repo, "select 1", []) do
      {:ok, _} -> 1
      _ -> 0
    end
  end
end
