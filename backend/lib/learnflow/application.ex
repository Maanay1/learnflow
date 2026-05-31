defmodule Learnflow.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Learnflow.Repo,
      {Finch, name: Learnflow.Finch},
      {DynamicSupervisor, strategy: :one_for_one, name: Learnflow.ObanSupervisor},
      {Phoenix.PubSub, name: Learnflow.PubSub},
      %{
        id: Learnflow.Messaging.Online,
        start: {Agent, :start_link, [fn -> %{} end, [name: Learnflow.Messaging.Online]]}
      },
      LearnflowWeb.Endpoint
    ]
    |> maybe_add_oban_starter()
    |> maybe_add_storage_setup()

    opts = [strategy: :one_for_one, name: Learnflow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LearnflowWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_add_storage_setup(children) do
    if Application.get_env(:learnflow, :storage_setup, true) do
      List.insert_at(children, 2, {Task, fn -> Learnflow.Storage.create_buckets_if_not_exist() end})
    else
      children
    end
  end

  defp maybe_add_oban_starter(children) do
    if Application.get_env(:learnflow, :start_oban, true) do
      List.insert_at(children, 3, Learnflow.ObanStarter)
    else
      children
    end
  end
end
