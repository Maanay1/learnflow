defmodule Learnflow.KeepAwake do
  @moduledoc """
  Keeps the Render free instance from sleeping.

  Render spins a free web service down after 15 minutes without inbound
  traffic, and the next visitor then waits ~45 seconds. While running on
  Render (`RENDER_EXTERNAL_URL` is set automatically) this process requests
  the public `/health` URL every 10 minutes, which counts as inbound traffic.
  Locally and in tests the variable is absent, so it does nothing.
  """
  use GenServer
  require Logger

  @interval :timer.minutes(10)

  def start_link(url), do: GenServer.start_link(__MODULE__, url, name: __MODULE__)

  @doc "Child spec list: empty unless running on Render."
  def children do
    case System.get_env("RENDER_EXTERNAL_URL") do
      url when is_binary(url) and url != "" -> [{__MODULE__, String.trim_trailing(url, "/") <> "/health"}]
      _ -> []
    end
  end

  @impl true
  def init(url) do
    schedule()
    {:ok, url}
  end

  @impl true
  def handle_info(:ping, url) do
    case Finch.build(:get, url) |> Finch.request(Learnflow.Finch, receive_timeout: 30_000) do
      {:ok, %{status: 200}} -> :ok
      other -> Logger.warning("KeepAwake ping failed: #{inspect(other, limit: 5)}")
    end

    schedule()
    {:noreply, url}
  end

  defp schedule, do: Process.send_after(self(), :ping, @interval)
end
