defmodule Learnflow.Analytics do
  import Ecto.Query
  alias Learnflow.Accounts.{Session, User}
  alias Learnflow.Analytics.Event
  alias Learnflow.Repo
  alias Learnflow.Videos.Video

  @admin_email "ada40vbayel@gmail.com"
  @recent_limit 30

  def admin?(%User{email: email}) when is_binary(email),
    do: String.downcase(email) == @admin_email

  def admin?(_), do: false

  def track(event_type, attrs \\ %{}) do
    attrs =
      attrs
      |> normalize_attrs()
      |> Map.put("event_type", event_type)

    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def summary do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    day_ago = DateTime.add(now, -24 * 60 * 60, :second)
    week_ago = DateTime.add(now, -7 * 24 * 60 * 60, :second)

    %{
      totals: %{
        users: Repo.aggregate(User, :count, :id),
        videos: Repo.aggregate(Video, :count, :id),
        active_videos: Repo.one(from v in Video, where: v.status == "active", select: count(v.id)),
        video_views: Repo.one(from v in Video, select: coalesce(sum(v.view_count), 0)),
        sessions: Repo.aggregate(Session, :count, :id),
        active_sessions: Repo.one(from s in Session, where: s.expires_at > ^now, select: count(s.id)),
        profile_views: count_events("profile_view"),
        logins: count_events(["login", "google_login"]),
        registrations: count_events(["register", "google_register"])
      },
      last_24h: %{
        new_users: Repo.one(from u in User, where: u.inserted_at >= ^day_ago, select: count(u.id)),
        sessions: Repo.one(from s in Session, where: s.inserted_at >= ^day_ago, select: count(s.id)),
        profile_views: count_events("profile_view", day_ago),
        logins: count_events(["login", "google_login"], day_ago)
      },
      last_7d: %{
        new_users: Repo.one(from u in User, where: u.inserted_at >= ^week_ago, select: count(u.id)),
        sessions: Repo.one(from s in Session, where: s.inserted_at >= ^week_ago, select: count(s.id)),
        profile_views: count_events("profile_view", week_ago),
        video_views: Repo.one(from v in Video, where: v.updated_at >= ^week_ago, select: coalesce(sum(v.view_count), 0))
      },
      top_profiles: top_profiles(),
      top_videos: top_videos(),
      recent_events: recent_events()
    }
  end

  defp count_events(types, since \\ nil) do
    types = List.wrap(types)

    Event
    |> where([e], e.event_type in ^types)
    |> maybe_since(since)
    |> Repo.aggregate(:count, :id)
  end

  defp top_profiles do
    Repo.all(
      from e in Event,
        join: u in User,
        on: u.id == e.target_user_id,
        where: e.event_type == "profile_view",
        group_by: [u.id, u.username, u.display_name, u.avatar_key, u.avatar_url],
        order_by: [desc: count(e.id)],
        limit: 8,
        select: %{
          id: u.id,
          username: u.username,
          display_name: u.display_name,
          avatar_key: u.avatar_key,
          avatar_url: u.avatar_url,
          views: count(e.id)
        }
    )
  end

  defp top_videos do
    Repo.all(
      from v in Video,
        left_join: u in assoc(v, :creator),
        where: v.status == "active",
        order_by: [desc: v.view_count, desc: v.inserted_at],
        limit: 8,
        select: %{
          id: v.id,
          title: v.title,
          slug: v.slug,
          format: v.format,
          views: v.view_count,
          creator_username: u.username,
          creator_display_name: u.display_name
        }
    )
  end

  defp recent_events do
    Repo.all(
      from e in Event,
        left_join: a in assoc(e, :actor),
        left_join: t in assoc(e, :target_user),
        order_by: [desc: e.inserted_at],
        limit: @recent_limit,
        select: %{
          id: e.id,
          event_type: e.event_type,
          inserted_at: e.inserted_at,
          metadata: e.metadata,
          actor: %{id: a.id, username: a.username, display_name: a.display_name, email: a.email},
          target_user: %{id: t.id, username: t.username, display_name: t.display_name}
        }
    )
  end

  defp maybe_since(query, nil), do: query
  defp maybe_since(query, since), do: where(query, [e], e.inserted_at >= ^since)

  defp normalize_attrs(attrs) do
    Enum.into(attrs, %{}, fn {key, value} -> {to_string(key), value} end)
  end
end
