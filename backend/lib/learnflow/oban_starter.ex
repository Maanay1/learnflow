defmodule Learnflow.ObanStarter do
  @moduledoc false
  use GenServer

  alias Ecto.Adapters.SQL
  alias Learnflow.Repo

  @interval 5_000

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(state) do
    send(self(), :maybe_start_oban)
    {:ok, state}
  end

  @impl true
  def handle_info(:maybe_start_oban, state) do
    if oban_ready?() do
      DynamicSupervisor.start_child(Learnflow.ObanSupervisor, {Oban, Application.fetch_env!(:learnflow, Oban)})
    else
      Process.send_after(self(), :maybe_start_oban, @interval)
    end

    {:noreply, state}
  end

  defp oban_ready? do
    case SQL.query(Repo, "select to_regclass('public.oban_jobs')", []) do
      {:ok, %{rows: [[table]]}} when not is_nil(table) -> true
      _ -> false
    end
  rescue
    _ -> false
  end
end
