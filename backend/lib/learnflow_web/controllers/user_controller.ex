defmodule LearnflowWeb.UserController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Dashboard}
  alias LearnflowWeb.VideoJSON

  def show(conn, %{"username" => username}) do
    case Dashboard.public_profile(username) do
      nil -> {:error, :not_found}
      profile -> json(conn, %{user: profile})
    end
  end

  def videos(conn, %{"username" => username} = params) do
    with user when not is_nil(user) <- Accounts.get_public_user(username) do
      {videos, next_cursor} = Dashboard.public_videos(user.id, params)
      json(conn, %{items: Enum.map(videos, &VideoJSON.video/1), next_cursor: next_cursor})
    else
      _ -> {:error, :not_found}
    end
  end

  def update(conn, params), do: with({:ok, user} <- Accounts.update_profile(conn.assigns.current_user, params), do: json(conn, %{user: Accounts.public_user(user)}))
  def delete(conn, _), do: with({:ok, _} <- Accounts.delete_account(conn.assigns.current_user), do: json(conn, %{ok: true}))
end
