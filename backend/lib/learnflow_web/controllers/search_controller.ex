defmodule LearnflowWeb.SearchController do
  use LearnflowWeb, :controller
  alias Learnflow.Videos
  alias LearnflowWeb.VideoJSON

  def index(conn, params) do
    {videos, next_cursor} = Videos.search_videos(params["q"], params)
    json(conn, %{items: Enum.map(videos, &VideoJSON.video/1), next_cursor: next_cursor})
  end
end
