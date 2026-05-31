import Config

database_url = System.get_env("DATABASE_URL") || "ecto://learnflow:devpassword123@localhost:5432/learnflow_dev"
port = System.get_env("PORT", "4000") |> String.to_integer()

config :learnflow, Learnflow.Repo,
  url: database_url,
  stacktrace: true,
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :learnflow, LearnflowWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: ["http://localhost:3000"],
  code_reloader: true,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "dev_secret_key_base_replace_in_production_64_bytes_minimum",
  watchers: []

config :ex_aws, :s3,
  scheme: "http://",
  host: System.get_env("MINIO_ENDPOINT", "http://localhost:9000") |> URI.parse() |> Map.get(:host),
  port: System.get_env("MINIO_ENDPOINT", "http://localhost:9000") |> URI.parse() |> Map.get(:port),
  access_key_id: System.get_env("MINIO_ACCESS_KEY", "minioadmin"),
  secret_access_key: System.get_env("MINIO_SECRET_KEY", "minioadmin123"),
  region: "us-east-1"
