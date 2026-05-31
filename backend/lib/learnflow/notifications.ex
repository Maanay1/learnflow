defmodule Learnflow.Notifications do
  import Ecto.Query

  alias Learnflow.Accounts.User
  alias Learnflow.Mailer
  alias Learnflow.Notifications.Notification
  alias Learnflow.Repo

  @page_size 20
  @email_types ~w(new_follower new_video_from_followed)

  def create_notification(user_id, type, attrs \\ %{}) do
    attrs =
      attrs
      |> normalize_attrs()
      |> Map.merge(%{"user_id" => user_id, "type" => to_string(type)})

    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, notification} ->
        notification = preload_notification(notification)
        Phoenix.PubSub.broadcast(Learnflow.PubSub, topic(user_id), {:new_notification, notification})
        maybe_send_email(notification)
        {:ok, notification}

      error ->
        error
    end
  end

  def list_notifications(user_id, cursor \\ nil) do
    cursor_tuple = parse_cursor(cursor)

    query =
      from n in Notification,
        where: n.user_id == ^user_id,
        order_by: [desc: n.inserted_at, desc: n.id],
        limit: ^(@page_size + 1),
        preload: [:actor, :video, :course, :comment]

    query =
      case cursor_tuple do
        nil -> query
        {inserted_at, id} -> where(query, [n], n.inserted_at < ^inserted_at or (n.inserted_at == ^inserted_at and n.id < ^id))
      end

    rows = Repo.all(query)
    page = Enum.take(rows, @page_size)
    next_cursor = if length(rows) > @page_size, do: encode_cursor(List.last(page)), else: nil
    {page, next_cursor, unread_count(user_id)}
  end

  def unread_count(user_id) do
    Repo.one(from n in Notification, where: n.user_id == ^user_id and is_nil(n.read_at), select: count())
  end

  def mark_read(user_id, notification_id) do
    now = utc_now()

    case Repo.one(from n in Notification, where: n.id == ^notification_id and n.user_id == ^user_id) do
      nil ->
        {:error, :not_found}

      notification ->
        notification
        |> Notification.changeset(%{read_at: now})
        |> Repo.update()
        |> case do
          {:ok, notification} -> {:ok, preload_notification(notification)}
          error -> error
        end
    end
  end

  def mark_all_read(user_id) do
    now = utc_now()
    {count, _} = Repo.update_all(from(n in Notification, where: n.user_id == ^user_id and is_nil(n.read_at)), set: [read_at: now])
    {:ok, count}
  end

  def unsubscribe(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :not_found}
      user -> user |> Ecto.Changeset.change(email_notifications: false) |> Repo.update()
    end
  end

  defp maybe_send_email(%Notification{type: type} = notification) when type in @email_types do
    notification = Repo.preload(notification, [:user, :actor, :video])

    if notification.user.email_notifications do
      Task.start(fn ->
        notification
        |> email()
        |> Mailer.deliver()
      end)
    end

    :ok
  end

  defp maybe_send_email(_notification), do: :ok

  defp email(notification) do
    message = text(notification)
    base = System.get_env("PUBLIC_URL", "http://localhost:3000")
    unsubscribe = "#{System.get_env("API_PUBLIC_URL", "http://localhost:4000")}/api/notifications/unsubscribe/#{notification.user.id}"

    Swoosh.Email.new()
    |> Swoosh.Email.to({notification.user.display_name || notification.user.username, notification.user.email})
    |> Swoosh.Email.from(email_from())
    |> Swoosh.Email.subject("LearnFlow: #{message}")
    |> Swoosh.Email.html_body("""
    <div style="font-family:Inter,Arial,sans-serif;background:#0f0f0f;color:#f5f5f5;padding:32px">
      <h1 style="color:#818cf8">LearnFlow</h1>
      <p style="font-size:18px">#{message}</p>
      <a href="#{base}" style="display:inline-block;background:#6366f1;color:white;padding:12px 18px;border-radius:8px;text-decoration:none">Открыть LearnFlow</a>
      <p style="margin-top:24px;font-size:12px;color:#a3a3a3"><a href="#{unsubscribe}" style="color:#a3a3a3">Отписаться от email-уведомлений</a></p>
    </div>
    """)
    |> Swoosh.Email.text_body("#{message}\n\n#{base}\nUnsubscribe: #{unsubscribe}")
  end

  defp email_from do
    Application.get_env(:learnflow, :email_from, "LearnFlow <noreply@learnflow.dev>")
  end

  def text(%Notification{type: "new_follower", actor: actor}), do: "#{name(actor)} подписался на вас"
  def text(%Notification{type: "new_video_from_followed", actor: actor, video: video}), do: "#{name(actor)} опубликовал новое видео: #{video && video.title}"
  def text(%Notification{type: "video_liked", actor: actor}), do: "#{name(actor)} поставил лайк вашему видео"
  def text(%Notification{type: "video_commented", actor: actor}), do: "#{name(actor)} прокомментировал ваше видео"
  def text(%Notification{type: "comment_replied", actor: actor}), do: "#{name(actor)} ответил на ваш комментарий"
  def text(%Notification{type: "course_completed"}), do: "Курс завершён. Сертификат готов"
  def text(_), do: "Новое уведомление"

  defp name(nil), do: "Пользователь"
  defp name(user), do: user.display_name || user.username || "Пользователь"

  defp preload_notification(notification), do: Repo.preload(notification, [:actor, :video, :course, :comment])
  defp topic(user_id), do: "notifications:#{user_id}"
  defp normalize_attrs(attrs), do: Map.new(attrs || %{}, fn {key, value} -> {to_string(key), value} end)
  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)

  defp encode_cursor(nil), do: nil
  defp encode_cursor(notification), do: Base.url_encode64("#{DateTime.to_iso8601(notification.inserted_at)}|#{notification.id}", padding: false)
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
