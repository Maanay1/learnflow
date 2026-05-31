defmodule LearnflowWeb.UserSocket do
  use Phoenix.Socket
  alias Learnflow.Accounts

  channel "feed:*", LearnflowWeb.FeedChannel
  channel "video:*", LearnflowWeb.VideoChannel
  channel "notifications:*", LearnflowWeb.NotificationChannel
  channel "conversation:*", LearnflowWeb.MessagingChannel

  @impl true
  def connect(%{"socket_token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(LearnflowWeb.Endpoint, "user socket", token, max_age: 86_400) do
      {:ok, user_id} ->
        case Learnflow.Repo.get(Learnflow.Accounts.User, user_id) do
          nil -> :error
          user -> {:ok, assign(socket, :current_user, user)}
        end

      _ ->
        :error
    end
  end

  def connect(%{"session_token" => token}, socket, _connect_info) do
    case Accounts.get_session_by_token(token) do
      nil ->
        :error

      session ->
        socket =
          socket
          |> assign(:current_user, session.user)
          |> assign(:current_session, session)

        {:ok, socket}
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
end
