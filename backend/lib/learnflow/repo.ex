defmodule Learnflow.Repo do
  use Ecto.Repo,
    otp_app: :learnflow,
    adapter: Ecto.Adapters.Postgres
end
