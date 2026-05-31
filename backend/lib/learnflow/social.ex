defmodule Learnflow.Social do
  import Ecto.Query
  alias Learnflow.Notifications
  alias Learnflow.Repo
  alias Learnflow.Social.{Comment, Follow, Like, Save}
  alias Learnflow.Videos.Video

  @like_cache :learnflow_like_counts
  @comment_limit 20

  def follow(follower_id, following_id) when follower_id == following_id, do: {:error, :cannot_follow_self}

  def follow(follower_id, following_id) do
    %Follow{}
    |> Follow.changeset(%{follower_id: follower_id, following_id: following_id})
    |> Repo.insert()
    |> case do
      {:ok, _follow} ->
        notify(following_id, "new_follower", %{actor_id: follower_id})
        Phoenix.PubSub.broadcast(Learnflow.PubSub, "user:#{following_id}", {:followed, follower_id})
        {:ok, :followed}

      {:error, changeset} ->
        if check_constraint_error?(changeset, :follower_id) do
          {:error, :cannot_follow_self}
        else
          {:error, :already_following}
        end
    end
  end

  def unfollow(follower_id, following_id) do
    {count, _} =
      Repo.delete_all(
        from f in Follow,
          where: f.follower_id == ^follower_id and f.following_id == ^following_id
      )

    if count == 1, do: {:ok, :unfollowed}, else: {:error, :not_following}
  end

  def is_following?(follower_id, following_id) do
    Repo.exists?(from f in Follow, where: f.follower_id == ^follower_id and f.following_id == ^following_id)
  end

  def get_followers_count(user_id), do: Repo.one(from f in Follow, where: f.following_id == ^user_id, select: count())
  def get_following_count(user_id), do: Repo.one(from f in Follow, where: f.follower_id == ^user_id, select: count())

  def like_video(user_id, video_id) do
    case %Like{} |> Like.changeset(%{user_id: user_id, video_id: video_id}) |> Repo.insert() do
      {:ok, _like} ->
        count = refresh_like_count(video_id)
        broadcast_video(video_id, {:like_added, count})
        Phoenix.PubSub.broadcast(Learnflow.PubSub, "feed:lobby", {:like_updated, video_id, count})
        notify_video_creator(video_id, user_id, "video_liked", %{actor_id: user_id, video_id: video_id})
        {:ok, :liked}

      {:error, _changeset} ->
        {:error, :already_liked}
    end
  end

  def unlike_video(user_id, video_id) do
    {count_deleted, _} = Repo.delete_all(from l in Like, where: l.user_id == ^user_id and l.video_id == ^video_id)

    if count_deleted == 1 do
      count = refresh_like_count(video_id)
      broadcast_video(video_id, {:like_removed, count})
      Phoenix.PubSub.broadcast(Learnflow.PubSub, "feed:lobby", {:like_updated, video_id, count})
      {:ok, :unliked}
    else
      {:error, :not_liked}
    end
  end

  def is_liked?(user_id, video_id), do: Repo.exists?(from l in Like, where: l.user_id == ^user_id and l.video_id == ^video_id)

  def get_like_count(video_id) do
    ensure_like_cache!()

    case :ets.lookup(@like_cache, video_id) do
      [{^video_id, count}] -> count
      [] -> refresh_like_count(video_id)
    end
  end

  def save_video(user_id, video_id) do
    %Save{}
    |> Save.changeset(%{user_id: user_id, video_id: video_id})
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:user_id, :video_id])
    |> case do
      {:ok, _save} ->
        Phoenix.PubSub.broadcast(Learnflow.PubSub, "video:#{video_id}", {:save_added, user_id})
        {:ok, :saved}

      {:error, changeset} -> {:error, changeset}
    end
  end

  def unsave_video(user_id, video_id) do
    Repo.delete_all(from s in Save, where: s.user_id == ^user_id and s.video_id == ^video_id)
    Phoenix.PubSub.broadcast(Learnflow.PubSub, "video:#{video_id}", {:save_removed, user_id})
    {:ok, :unsaved}
  end

  def is_saved?(user_id, video_id), do: Repo.exists?(from s in Save, where: s.user_id == ^user_id and s.video_id == ^video_id)

  def create_comment(user_id, video_id, body, parent_id \\ nil) do
    with :ok <- validate_parent(video_id, parent_id),
         {:ok, comment} <-
           %Comment{}
           |> Comment.changeset(%{user_id: user_id, video_id: video_id, body: body, parent_id: parent_id})
           |> Repo.insert() do
      comment = Repo.preload(comment, [:user])
      broadcast_video(video_id, {:new_comment, comment})
      notify_video_creator(video_id, user_id, "video_commented", %{actor_id: user_id, video_id: video_id, comment_id: comment.id})
      notify_parent_author(parent_id, user_id, video_id, comment.id)
      {:ok, comment}
    end
  end

  def delete_comment(user_id, comment_id) do
    comment =
      case Repo.get(Comment, comment_id) do
        nil -> nil
        comment -> Repo.preload(comment, :video)
      end

    cond do
      is_nil(comment) ->
        {:error, :not_found}

      comment.user_id == user_id or comment.video.creator_id == user_id ->
        comment
        |> Comment.changeset(%{is_deleted: true, body: "[deleted]"})
        |> Repo.update()

      true ->
        {:error, :unauthorized}
    end
  end

  def list_comments(video_id, cursor \\ nil) do
    cursor_tuple = parse_cursor(cursor)

    query =
      from c in Comment,
        where: c.video_id == ^video_id and is_nil(c.parent_id),
        order_by: [desc: c.inserted_at, desc: c.id],
        limit: ^(@comment_limit + 1),
        preload: [
          :user,
          replies: ^from(r in Comment, order_by: [asc: r.inserted_at, asc: r.id], preload: [:user])
        ]

    query =
      case cursor_tuple do
        nil -> query
        {inserted_at, id} -> where(query, [c], c.inserted_at < ^inserted_at or (c.inserted_at == ^inserted_at and c.id < ^id))
      end

    query
    |> Repo.all()
    |> split_page()
  end

  def counts(video_id), do: %{likes: get_like_count(video_id), comments: comments_count(video_id)}

  defp validate_parent(_video_id, nil), do: :ok

  defp validate_parent(video_id, parent_id) do
    case Repo.get(Comment, parent_id) do
      nil -> {:error, :invalid_parent}
      %Comment{video_id: ^video_id, parent_id: nil} -> :ok
      %Comment{video_id: ^video_id} -> {:error, :max_depth}
      _ -> {:error, :invalid_parent}
    end
  end

  defp refresh_like_count(video_id) do
    ensure_like_cache!()
    count = Repo.one(from l in Like, where: l.video_id == ^video_id, select: count())
    :ets.insert(@like_cache, {video_id, count})
    count
  end

  defp ensure_like_cache! do
    case :ets.whereis(@like_cache) do
      :undefined -> :ets.new(@like_cache, [:named_table, :public, read_concurrency: true, write_concurrency: true])
      _ -> :ok
    end
  rescue
    ArgumentError -> :ok
  end

  defp broadcast_video(video_id, message), do: Phoenix.PubSub.broadcast(Learnflow.PubSub, "video:#{video_id}", message)
  defp comments_count(video_id), do: Repo.one(from c in Comment, where: c.video_id == ^video_id and not c.is_deleted, select: count())

  defp notify(user_id, _type, _attrs) when is_nil(user_id), do: :ok
  defp notify(user_id, type, attrs), do: Notifications.create_notification(user_id, type, attrs)

  defp check_constraint_error?(%Ecto.Changeset{} = changeset, field) do
    Enum.any?(Keyword.get_values(changeset.errors, field), fn {_message, opts} ->
      Keyword.get(opts, :constraint) == :check
    end)
  end

  defp notify_video_creator(video_id, actor_id, type, attrs) do
    case Repo.get(Video, video_id) do
      %Video{creator_id: creator_id} when creator_id != actor_id -> notify(creator_id, type, attrs)
      _ -> :ok
    end
  end

  defp notify_parent_author(nil, _actor_id, _video_id, _comment_id), do: :ok

  defp notify_parent_author(parent_id, actor_id, video_id, comment_id) do
    case Repo.get(Comment, parent_id) do
      %Comment{user_id: user_id} when user_id != actor_id ->
        notify(user_id, "comment_replied", %{actor_id: actor_id, video_id: video_id, comment_id: comment_id})

      _ ->
        :ok
    end
  end

  defp split_page(rows) do
    comments = Enum.take(rows, @comment_limit)
    next_cursor = if length(rows) > @comment_limit, do: encode_cursor(List.last(comments)), else: nil
    {comments, next_cursor}
  end

  defp encode_cursor(nil), do: nil
  defp encode_cursor(comment), do: Base.url_encode64("#{DateTime.to_iso8601(comment.inserted_at)}|#{comment.id}", padding: false)
  defp parse_cursor(nil), do: nil
  defp parse_cursor(""), do: nil
  defp parse_cursor(cursor) do
    with {:ok, decoded} <- Base.url_decode64(cursor, padding: false),
         [timestamp, id] <- String.split(decoded, "|"),
         {:ok, inserted_at, _} <- DateTime.from_iso8601(timestamp) do
      {inserted_at, id}
    else
      _ -> nil
    end
  end
end
