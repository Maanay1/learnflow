defmodule LearnflowWeb do
  def controller do
    quote do
      use Phoenix.Controller, formats: [:json]
      import Plug.Conn
      alias LearnflowWeb.Router.Helpers, as: Routes
      action_fallback LearnflowWeb.FallbackController
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LearnflowWeb.Endpoint,
        router: LearnflowWeb.Router
    end
  end

  defmacro __using__(which) when is_atom(which), do: apply(__MODULE__, which, [])
end
