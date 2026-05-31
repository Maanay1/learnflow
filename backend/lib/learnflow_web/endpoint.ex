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
    origins: [
      "http://localhost:3000",
      "https://learnflow-c5n9v2sbg-ada40vbayel-5500s-projects.vercel.app",
      ~r{https://learnflow.*\.vercel\.app}
    ],
    allow_headers: ["content-type", "authorization", "x-csrf-token"],
    allow_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_credentials: true

  plug LearnflowWeb.Router
end
