defmodule LearnflowWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint LearnflowWeb.Endpoint

      import Phoenix.ChannelTest
      import LearnflowWeb.ChannelCase
    end
  end

  setup tags do
    Learnflow.DataCase.setup_sandbox(tags)
    :ok
  end
end
