defmodule LearnflowWeb.Plugs.RateLimit do
  import Plug.Conn
  import Phoenix.Controller

  @table :learnflow_rate_limits
  @window_seconds 60

  def init(opts), do: opts

  def call(conn, opts) do
    ensure_table!()

    limit = Keyword.get(opts, :limit, 100)
    bucket_name = Keyword.get(opts, :bucket, limit)
    now = System.system_time(:second)
    bucket = div(now, @window_seconds)
    key = {client_ip(conn), bucket_name, bucket}

    count = :ets.update_counter(@table, key, {2, 1}, {key, 0})

    if count > limit do
      retry_after = ((bucket + 1) * @window_seconds) - now

      conn
      |> put_resp_header("retry-after", Integer.to_string(max(retry_after, 1)))
      |> put_status(:too_many_requests)
      |> json(%{error: "rate_limited"})
      |> halt()
    else
      conn
    end
  end

  defp ensure_table! do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :public, read_concurrency: true, write_concurrency: true])

      _tid ->
        :ok
    end
  rescue
    ArgumentError -> :ok
  end

  defp client_ip(conn), do: conn.remote_ip |> :inet.ntoa() |> to_string()
end
