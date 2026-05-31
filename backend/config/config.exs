import Config

config :learnflow,
  ecto_repos: [Learnflow.Repo],
  generators: [timestamp_type: :utc_datetime]

config :learnflow, :minio,
  endpoint: System.get_env("MINIO_ENDPOINT", "http://localhost:9000"),
  access_key_id: System.get_env("MINIO_ACCESS_KEY", "minioadmin"),
  secret_access_key: System.get_env("MINIO_SECRET_KEY", "minioadmin123"),
  bucket_videos: System.get_env("MINIO_BUCKET_VIDEOS", "learnflow-videos"),
  bucket_thumbnails: System.get_env("MINIO_BUCKET_THUMBNAILS", "learnflow-thumbnails")

config :learnflow, LearnflowWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: LearnflowWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Learnflow.PubSub,
  live_view: [signing_salt: "learnflow-signing"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ex_aws,
  json_codec: Jason

config :learnflow, Oban,
  repo: Learnflow.Repo,
  queues: [ai: 5],
  plugins: [Oban.Plugins.Pruner]

import_config "#{config_env()}.exs"
