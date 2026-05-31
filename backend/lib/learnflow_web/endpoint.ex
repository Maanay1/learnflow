defmodule LearnflowWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :learnflow

  @session_options [
    store: :cookie,
    key: "_learnflow_key",
    signing_salt: "learnflow-session",
    same_site: "Strict"
  ]

  socket "/socket", LearnflowWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :learnflow,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"], json_decoder: Phoenix.json_library()
  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug Corsica,
    origins: {__MODULE__, :cors_origin_allowed?, []},
    allow_headers: ["content-type", "authorization", "x-csrf-token"],
    allow_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_credentials: true

  plug LearnflowWeb.Router

  def cors_origin_allowed?(_conn, origin) do
    origin in allowed_origins() or Regex.match?(~r{^https://learnflow.*\.vercel\.app$}, origin)
  end

  defp allowed_origins do
    [
      "http://localhost:3000",
      "http://127.0.0.1:3000",
      "https://jarq.me",
      "https://www.jarq.me",
      System.get_env("FRONTEND_URL"),
      System.get_env("PUBLIC_URL")
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&String.trim_trailing(&1, "/"))
  end
end
