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
  plug LearnflowWeb.Plugs.CORS
  plug LearnflowWeb.Router
end
