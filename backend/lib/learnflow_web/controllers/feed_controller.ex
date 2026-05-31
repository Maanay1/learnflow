defmodule LearnflowWeb.FeedController do
  use LearnflowWeb, :controller
  alias Learnflow.{Accounts, Videos}
  alias LearnflowWeb.VideoJSON

  def index(conn, params) do
    user = Accounts.get_user_by_session_token(conn.req_cookies["session_token"]) || %{id: Ecto.UUID.generate()}
    {videos, next_cursor} = Videos.get_feed(user, params)
    json(conn, %{items: Enum.map(videos, &VideoJSON.video/1), next_cursor: next_cursor})
  end
end
