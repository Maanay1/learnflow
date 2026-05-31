defmodule LearnflowWeb.SocialController do
  use LearnflowWeb, :controller
  alias Learnflow.Social

  def follow(conn, %{"id" => id}) do
    with {:ok, result} <- Social.follow(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result})
    end
  end

  def unfollow(conn, %{"id" => id}) do
    with {:ok, result} <- Social.unfollow(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result})
    end
  end

  def like(conn, %{"id" => id}) do
    with {:ok, result} <- Social.like_video(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result, like_count: Social.get_like_count(id)})
    end
  end

  def unlike(conn, %{"id" => id}) do
    with {:ok, result} <- Social.unlike_video(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result, like_count: Social.get_like_count(id)})
    end
  end

  def save(conn, %{"id" => id}) do
    with {:ok, result} <- Social.save_video(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result})
    end
  end

  def unsave(conn, %{"id" => id}) do
    with {:ok, result} <- Social.unsave_video(conn.assigns.current_user.id, id) do
      json(conn, %{ok: true, status: result})
    end
  end

  def comments(conn, %{"id" => id} = params) do
    {comments, next_cursor} = Social.list_comments(id, params["cursor"])
    json(conn, %{comments: Enum.map(comments, &comment_json/1), next_cursor: next_cursor})
  end

  def comment(conn, %{"id" => id, "body" => body} = params) do
    with {:ok, comment} <- Social.create_comment(conn.assigns.current_user.id, id, body, params["parent_id"]) do
      conn
      |> put_status(:created)
      |> json(%{comment: comment_json(comment)})
    end
  end

  def delete_comment(conn, %{"id" => id}) do
    with {:ok, comment} <- Social.delete_comment(conn.assigns.current_user.id, id) do
      json(conn, %{comment: comment_json(comment)})
    end
  end

  def comment_json(comment) do
    %{
      id: comment.id,
      video_id: comment.video_id,
      parent_id: comment.parent_id,
      body: comment.body,
      is_deleted: comment.is_deleted,
      inserted_at: comment.inserted_at,
      user: comment |> loaded_one(:user) |> Learnflow.Accounts.public_user(),
      replies: comment |> loaded_assoc(:replies) |> Enum.map(&comment_json/1)
    }
  end

  defp loaded_assoc(struct, field) do
    case Map.get(struct, field) do
      %Ecto.Association.NotLoaded{} -> []
      nil -> []
      values -> values
    end
  end

  defp loaded_one(struct, field) do
    case Map.get(struct, field) do
      %Ecto.Association.NotLoaded{} -> nil
      value -> value
    end
  end
end
