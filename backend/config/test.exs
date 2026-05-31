import Config

config :learnflow, Learnflow.Repo,
  url: System.get_env("TEST_DATABASE_URL") || "ecto://learnflow:devpassword123@localhost:5432/learnflow_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :learnflow, LearnflowWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_replace_in_real_test_env_64_bytes_minimum",
  server: false

config :logger, level: :warning

config :learnflow, :storage_setup, false
config :learnflow, :start_oban, false
