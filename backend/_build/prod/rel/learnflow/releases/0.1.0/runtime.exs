import Config

unless config_env() == :test do
  database_url = System.get_env("DATABASE_URL") || "ecto://learnflow:devpassword123@localhost:5432/learnflow_dev"
  port = System.get_env("PORT", "4000") |> String.to_integer()
  phx_host = System.get_env("PHX_HOST") || System.get_env("RAILWAY_PUBLIC_DOMAIN") || "localhost"
  url_scheme = System.get_env("URL_SCHEME", if(System.get_env("COOKIE_SECURE", "false") == "true", do: "https", else: "http"))
  minio_endpoint = System.get_env("MINIO_ENDPOINT", "http://localhost:9000")
  minio_uri = URI.parse(minio_endpoint)
  frontend_url = System.get_env("FRONTEND_URL") || System.get_env("PUBLIC_URL") || "http://localhost:3000"
  api_public_url = System.get_env("API_PUBLIC_URL") || "#{url_scheme}://#{phx_host}"
  check_origins =
    [frontend_url, System.get_env("PUBLIC_URL"), api_public_url, "https://#{phx_host}", "http://#{phx_host}"]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()

  config :learnflow, Learnflow.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
    ssl: System.get_env("DATABASE_SSL", "false") == "true",
    show_sensitive_data_on_connection_error: false

  config :learnflow, LearnflowWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: port],
    url: [scheme: url_scheme, host: phx_host, port: if(url_scheme == "https", do: 443, else: port)],
    check_origin: check_origins,
    secret_key_base: System.get_env("SECRET_KEY_BASE", "dev_secret_key_base_change_me_for_production_64_bytes_minimum"),
    server: true

  config :learnflow, :minio,
    endpoint: minio_endpoint,
    access_key_id: System.get_env("MINIO_ACCESS_KEY", "minioadmin"),
    secret_access_key: System.get_env("MINIO_SECRET_KEY", "minioadmin123"),
    bucket_videos: System.get_env("MINIO_BUCKET_VIDEOS", "learnflow-videos"),
    bucket_thumbnails: System.get_env("MINIO_BUCKET_THUMBNAILS", "learnflow-thumbnails"),
    bucket_certificates: System.get_env("MINIO_BUCKET_CERTIFICATES", "learnflow-certificates")

  config :ex_aws, :s3,
    scheme: "#{minio_uri.scheme}://",
    host: minio_uri.host,
    port: minio_uri.port,
    access_key_id: System.get_env("MINIO_ACCESS_KEY", "minioadmin"),
    secret_access_key: System.get_env("MINIO_SECRET_KEY", "minioadmin123"),
    region: "us-east-1"

  config :learnflow, :urls,
    frontend_url: frontend_url,
    public_url: System.get_env("PUBLIC_URL", frontend_url),
    api_public_url: api_public_url

  config :learnflow, :twilio,
    account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
    auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
    phone: System.get_env("TWILIO_PHONE")

  config :stripity_stripe,
    api_key: System.get_env("STRIPE_SECRET_KEY")
end

config :learnflow, Learnflow.Mailer,
  adapter:
    if(System.get_env("SMTP_HOST") in [nil, ""],
      do: Swoosh.Adapters.Local,
      else: Swoosh.Adapters.SMTP
    ),
  relay: System.get_env("SMTP_HOST"),
  port: String.to_integer(System.get_env("SMTP_PORT", "587")),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :if_available,
  auth: :if_available,
  no_mx_lookups: true

config :learnflow, :email_from, System.get_env("EMAIL_FROM", "LearnFlow <noreply@learnflow.dev>")

config :learnflow, :openai,
  api_key: System.get_env("OPENAI_API_KEY")
