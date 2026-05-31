defmodule LearnflowWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint LearnflowWeb.Endpoint

      use LearnflowWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import LearnflowWeb.ConnCase
    end
  end

  setup tags do
    Learnflow.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
