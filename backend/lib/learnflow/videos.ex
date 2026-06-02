defmodule Learnflow.Videos do
  import Ecto.Query
  alias Learnflow.Dashboard.{Certificate, PlaylistVideo}
  alias Learnflow.Notifications
  alias Learnflow.Repo
  alias Learnflow.Social.Follow
  alias Learnflow.Social.{Like, Save}
  alias Learnflow.Storage
  alias Learnflow.Videos.{SubjectTag, Video, VideoChapter, WatchProgress}
  alias Learnflow.Workers.TranscribeVideoJob

  @allowed_video_content_types %{"video/mp4" => "mp4", "video/webm" => "webm"}
  @allowed_thumbnail_content_types %{
    "image/jpeg" => "jpg",
    "image/png" => "png",
    "image/webp" => "webp"
  }
  @max_video_bytes 2_000_000_000
  @default_limit 20
  @max_limit 50

  def create_video(creator, attrs) do
    attrs = normalize_attrs(attrs)
    title = Map.get(attrs, "title")

    video_attrs =
      attrs
      |> Map.put("creator_id", creator.id)
      |> Map.put("slug", unique_slug(title))
      |> Map.put("status", "pending")

    with {:ok, video} <- %Video{} |> Video.changeset(video_attrs) |> Repo.insert(),
         {:ok, video} <- attach_tags(video, Map.get(attrs, "tags", [])) do
      {:ok, preload_video(video)}
    end
  end

  def request_upload_url(%Video{} = video, content_type, file_size_bytes) do
    with {:ok, ext} <- video_extension(content_type),
         :ok <- validate_video_size(file_size_bytes) do
      key = "videos/#{video.id}/source.#{ext}"

      with {:ok, url} <-
             Storage.generate_upload_url(
               Storage.bucket_videos(),
               key,
               content_type,
               file_size_bytes
             ) do
        {:ok, url, key}
      end
    end
  end

  def request_thumbnail_upload_url(%Video{} = video, content_type) do
    with {:ok, ext} <- thumbnail_extension(content_type) do
      key = "thumbnails/#{video.id}/thumb.#{ext}"

      with {:ok, url} <-
             Storage.generate_upload_url(
               Storage.bucket_thumbnails(),
               key,
               content_type,
               25_000_000
             ) do
        {:ok, url, key}
      end
    end
  end

  def confirm_upload(%Video{} = video, attrs) do
    attrs =
      attrs
      |> normalize_attrs()
      |> Map.take(["video_key", "thumbnail_key", "duration_seconds"])
      |> Map.put("status", "active")

    video
    |> Video.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated} ->
        notify_followers_new_video(updated)
        schedule_ai_processing(updated)
        {:ok, updated}

      error ->
        error
    end
  end

  def get_video_view_url(%Video{status: "active", video_key: key}, user, session_id)
      when is_binary(key) and key != "" do
    if String.starts_with?(key, "http") do
      {:ok, key}
    else
      Storage.generate_view_url(Storage.bucket_videos(), key, user.id, session_id)
    end
  end

  def get_video_view_url(_video, _user, _session_id), do: {:error, :video_unavailable}

  def get_public_video_view_url(%Video{status: "active", video_key: key})
      when is_binary(key) and key != "" do
    if String.starts_with?(key, "http") do
      {:ok, key}
    else
      Storage.generate_read_url(Storage.bucket_videos(), key)
    end
  end

  def get_public_video_view_url(_video), do: {:error, :video_unavailable}

  def decorate_media_urls(videos) when is_list(videos), do: decorate_thumbnail_urls(videos)
  def decorate_media_urls(%Video{} = video), do: decorate_thumbnail_url(video)

  def get_feed(user, opts \\ %{}) do
    opts = normalize_opts(opts)
    limit = limit(opts)
    tags = list_opt(opts, "tags")
    cursor = parse_cursor(Map.get(opts, "cursor"))

    query =
      from(v in Video,
        where: v.status == "active",
        preload: [:creator, :tags],
        limit: ^(limit + 1)
      )

    query =
      query
      |> maybe_filter(:format, Map.get(opts, "format"))
      |> maybe_boost_followed(user)
      |> maybe_filter(:difficulty, Map.get(opts, "difficulty"))
      |> maybe_filter(:language, Map.get(opts, "language"))
      |> maybe_filter_tags(tags)
      |> maybe_cursor(cursor)
      |> order_feed(user)

    query
    |> Repo.all()
    |> decorate_thumbnail_urls()
    |> split_page(limit)
  end

  def get_video_by_slug(slug, viewer_id \\ nil) do
    video =
      Video
      |> where([v], v.slug == ^slug and v.status == "active")
      |> preload([
        :creator,
        :tags,
        chapters: ^from(c in VideoChapter, order_by: [asc: c.position])
      ])
      |> Repo.one()

    if video do
      Task.start(fn -> increment_view_count(video.id) end)

      video
      |> decorate_viewer_flags(viewer_id)
      |> decorate_thumbnail_url()
    end
  end

  def search_videos(query_string, opts \\ %{}) do
    opts = normalize_opts(opts)
    limit = limit(opts)
    tags = list_opt(opts, "tags")
    cursor = parse_cursor(Map.get(opts, "cursor"))
    query_string = String.trim(to_string(query_string))

    if query_string == "" do
      {[], nil}
    else
      Video
      |> where([v], v.status == "active")
      |> where([v], fragment("? @@ plainto_tsquery('simple', ?)", v.search_vector, ^query_string))
      |> maybe_filter(:difficulty, Map.get(opts, "difficulty"))
      |> maybe_filter(:language, Map.get(opts, "language"))
      |> maybe_duration(Map.get(opts, "duration_max_seconds") || Map.get(opts, "duration_max"))
      |> maybe_filter_tags(tags)
      |> maybe_cursor(cursor)
      |> order_by([v],
        desc:
          fragment("ts_rank(?, plainto_tsquery('simple', ?))", v.search_vector, ^query_string),
        desc: v.inserted_at,
        desc: v.id
      )
      |> limit(^(limit + 1))
      |> preload([:creator, :tags])
      |> Repo.all()
      |> decorate_thumbnail_urls()
      |> split_page(limit)
    end
  end

  def update_watch_progress(user_id, video_id, seconds_watched) do
    now = utc_now()
    seconds_watched = seconds_watched |> to_integer() |> max(0)
    video = get_video_by_id(video_id)
    seconds_watched = clamp_watch_seconds(seconds_watched, video)
    completed = completed_by_duration?(seconds_watched, video)

    attrs = %{
      user_id: user_id,
      video_id: video_id,
      seconds_watched: seconds_watched,
      completed: completed,
      last_watched_at: now
    }

    conflict_set =
      [
        seconds_watched: seconds_watched,
        last_watched_at: now,
        updated_at: now
      ] ++ if(completed, do: [completed: true], else: [])

    %WatchProgress{}
    |> WatchProgress.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: conflict_set],
      conflict_target: [:user_id, :video_id],
      returning: true
    )
  end

  def get_watch_progress(user_id, video_id) do
    Repo.get_by(WatchProgress, user_id: user_id, video_id: video_id) ||
      %WatchProgress{user_id: user_id, video_id: video_id, seconds_watched: 0, completed: false}
  end

  def mark_completed(user_id, video_id) do
    now = utc_now()

    Repo.transaction(fn ->
      progress =
        %WatchProgress{}
        |> WatchProgress.changeset(%{
          user_id: user_id,
          video_id: video_id,
          completed: true,
          last_watched_at: now
        })
        |> Repo.insert!(
          on_conflict: [set: [completed: true, last_watched_at: now, updated_at: now]],
          conflict_target: [:user_id, :video_id],
          returning: true
        )

      maybe_issue_certificates(user_id)
      progress
    end)
  end

  def add_chapters(%Video{} = video, chapters_list) when is_list(chapters_list) do
    Repo.transaction(fn ->
      Repo.delete_all(from(c in VideoChapter, where: c.video_id == ^video.id))

      chapters =
        chapters_list
        |> Enum.map(&chapter_attrs(video.id, &1))
        |> Enum.map(fn attrs ->
          %VideoChapter{}
          |> VideoChapter.changeset(attrs)
          |> Repo.insert!()
        end)

      chapters
    end)
  end

  def get_video_by_id(id), do: Repo.get(Video, id)

  def creator_videos(user_id) do
    Video
    |> where([v], v.creator_id == ^user_id and v.status == "active")
    |> preload([:tags, :creator])
    |> order_by([v], desc: v.inserted_at)
    |> Repo.all()
    |> decorate_thumbnail_urls()
  end

  defp maybe_issue_certificates(user_id) do
    playlist_ids =
      Repo.all(
        from(pv in PlaylistVideo,
          join: p in assoc(pv, :playlist),
          where: p.user_id == ^user_id,
          group_by: pv.playlist_id,
          select: pv.playlist_id
        )
      )

    Enum.each(playlist_ids, fn playlist_id ->
      complete? =
        Repo.one(
          from(pv in PlaylistVideo,
            left_join: wp in WatchProgress,
            on: wp.video_id == pv.video_id and wp.user_id == ^user_id and wp.completed == true,
            where: pv.playlist_id == ^playlist_id,
            select: count(pv.video_id) == count(wp.video_id)
          )
        )

      if complete? do
        cert_no = "LF-#{String.slice(user_id, 0, 8)}-#{String.slice(playlist_id, 0, 8)}"

        %Certificate{}
        |> Certificate.changeset(%{
          user_id: user_id,
          playlist_id: playlist_id,
          certificate_number: cert_no,
          issued_at: utc_now()
        })
        |> Repo.insert(on_conflict: :nothing, conflict_target: :certificate_number)
      end
    end)
  end

  defp attach_tags(video, []), do: {:ok, video}

  defp attach_tags(video, tags) when is_list(tags) do
    tag_slugs = Enum.map(tags, &slugify/1)
    tag_rows = Repo.all(from(t in SubjectTag, where: t.slug in ^tag_slugs))
    now = utc_now()

    Repo.delete_all(from(vt in Learnflow.Videos.VideoTag, where: vt.video_id == ^video.id))

    rows =
      Enum.map(tag_rows, fn tag ->
        %{video_id: video.id, tag_id: tag.id, inserted_at: now, updated_at: now}
      end)

    if rows != [], do: Repo.insert_all(Learnflow.Videos.VideoTag, rows)
    {:ok, Repo.preload(video, :tags, force: true)}
  end

  defp preload_video(video), do: Repo.preload(video, [:creator, :tags, :chapters])

  defp decorate_thumbnail_urls(videos) when is_list(videos),
    do: Enum.map(videos, &decorate_thumbnail_url/1)

  defp decorate_thumbnail_url(%Video{thumbnail_key: key} = video)
       when is_binary(key) and key != "" do
    cond do
      String.starts_with?(key, ["http://", "https://"]) ->
        %{video | thumbnail_url: key}

      true ->
        case Storage.generate_read_url(Storage.bucket_thumbnails(), key) do
          {:ok, url} -> %{video | thumbnail_url: url}
          _ -> video
        end
    end
  end

  defp decorate_thumbnail_url(video), do: video

  defp unique_slug(title) do
    base =
      title
      |> slugify()
      |> case do
        "" -> "video"
        slug -> slug
      end

    "#{base}-#{Ecto.UUID.generate() |> String.slice(0, 8)}"
  end

  defp slugify(value) do
    value
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
  end

  defp video_extension(content_type),
    do: content_type_lookup(@allowed_video_content_types, content_type, :invalid_video_type)

  defp thumbnail_extension(content_type),
    do:
      content_type_lookup(@allowed_thumbnail_content_types, content_type, :invalid_thumbnail_type)

  defp content_type_lookup(map, content_type, error) do
    case Map.fetch(map, to_string(content_type)) do
      {:ok, ext} -> {:ok, ext}
      :error -> {:error, error}
    end
  end

  defp validate_video_size(size) when is_integer(size) and size <= @max_video_bytes and size > 0,
    do: :ok

  defp validate_video_size(size) when is_binary(size),
    do: size |> String.to_integer() |> validate_video_size()

  defp validate_video_size(_size), do: {:error, :file_too_large}

  defp clamp_watch_seconds(seconds, %Video{duration_seconds: duration})
       when is_integer(duration) and duration > 0,
       do: min(seconds, duration)

  defp clamp_watch_seconds(seconds, _video), do: seconds

  defp completed_by_duration?(seconds, %Video{duration_seconds: duration})
       when is_integer(duration) and duration > 0 do
    seconds / duration >= 0.95
  end

  defp completed_by_duration?(_seconds, _video), do: false

  defp maybe_boost_followed(query, nil), do: query
  defp maybe_boost_followed(query, %{id: nil}), do: query
  defp maybe_boost_followed(query, _user), do: query

  defp order_feed(query, nil), do: order_by(query, [v], desc: v.inserted_at, desc: v.id)

  defp order_feed(query, %{id: user_id}) do
    order_by(query, [v],
      desc:
        fragment(
          "CASE WHEN EXISTS (SELECT 1 FROM follows f WHERE f.follower_id = ? AND f.following_id = ?) THEN 1 ELSE 0 END",
          type(^user_id, :binary_id),
          v.creator_id
        ),
      desc: v.inserted_at,
      desc: v.id
    )
  end

  defp maybe_filter(query, _field, nil), do: query
  defp maybe_filter(query, _field, ""), do: query
  defp maybe_filter(query, field, value), do: where(query, [v], field(v, ^field) == ^value)

  defp maybe_duration(query, nil), do: query
  defp maybe_duration(query, ""), do: query

  defp maybe_duration(query, seconds),
    do: where(query, [v], v.duration_seconds <= ^to_integer(seconds))

  defp maybe_filter_tags(query, []), do: query

  defp maybe_filter_tags(query, tags),
    do: join(query, :inner, [v], t in assoc(v, :tags), on: t.slug in ^tags)

  defp maybe_cursor(query, nil), do: query

  defp maybe_cursor(query, {inserted_at, id}),
    do:
      where(
        query,
        [v],
        v.inserted_at < ^inserted_at or (v.inserted_at == ^inserted_at and v.id < ^id)
      )

  defp split_page(rows, limit) do
    videos = Enum.take(rows, limit)
    next_cursor = if length(rows) > limit, do: encode_cursor(List.last(videos)), else: nil
    {videos, next_cursor}
  end

  defp encode_cursor(nil), do: nil

  defp encode_cursor(video),
    do: Base.url_encode64("#{DateTime.to_iso8601(video.inserted_at)}|#{video.id}", padding: false)

  defp parse_cursor(nil), do: nil
  defp parse_cursor(""), do: nil

  defp parse_cursor(cursor) do
    decoded =
      Base.url_decode64(cursor, padding: false)
      |> case do
        {:ok, value} -> value
        :error -> cursor
      end

    case String.split(decoded, "|") do
      [timestamp, id] ->
        {:ok, inserted_at, _} = DateTime.from_iso8601(timestamp)
        {inserted_at, id}

      [id] ->
        case Repo.get(Video, id) do
          nil -> nil
          video -> {video.inserted_at, video.id}
        end
    end
  rescue
    _ -> nil
  end

  defp decorate_viewer_flags(video, nil),
    do: Map.merge(video, %{is_liked: false, is_saved: false})

  defp decorate_viewer_flags(video, viewer_id) do
    is_liked =
      Repo.exists?(from(l in Like, where: l.user_id == ^viewer_id and l.video_id == ^video.id))

    is_saved =
      Repo.exists?(from(s in Save, where: s.user_id == ^viewer_id and s.video_id == ^video.id))

    Map.merge(video, %{is_liked: is_liked, is_saved: is_saved})
  end

  defp increment_view_count(video_id),
    do: Repo.update_all(from(v in Video, where: v.id == ^video_id), inc: [view_count: 1])

  defp notify_followers_new_video(%Video{status: "active"} = video) do
    follower_ids =
      Repo.all(
        from(f in Follow, where: f.following_id == ^video.creator_id, select: f.follower_id)
      )

    Enum.each(follower_ids, fn user_id ->
      Notifications.create_notification(user_id, "new_video_from_followed", %{
        actor_id: video.creator_id,
        video_id: video.id
      })
    end)
  end

  defp notify_followers_new_video(_video), do: :ok

  defp schedule_ai_processing(%Video{id: id, video_key: key}) when is_binary(key) and key != "" do
    if Application.get_env(:learnflow, :start_oban, true) do
      %{video_id: id}
      |> TranscribeVideoJob.new(schedule_in: 60)
      |> Oban.insert()
    end

    :ok
  end

  defp schedule_ai_processing(_video), do: :ok

  defp chapter_attrs(video_id, {title, start_seconds, position}),
    do: %{video_id: video_id, title: title, start_seconds: start_seconds, position: position}

  defp chapter_attrs(video_id, attrs),
    do: attrs |> normalize_attrs() |> Map.put("video_id", video_id)

  defp list_opt(opts, key) do
    case Map.get(opts, key) do
      nil -> []
      value when is_binary(value) -> String.split(value, ",", trim: true)
      value when is_list(value) -> value
    end
  end

  defp limit(opts),
    do: opts |> Map.get("limit", @default_limit) |> to_integer() |> min(@max_limit) |> max(1)

  defp to_integer(value) when is_integer(value), do: value
  defp to_integer(value) when is_binary(value), do: String.to_integer(value)

  defp normalize_attrs(attrs),
    do: Map.new(attrs || %{}, fn {key, value} -> {to_string(key), value} end)

  defp normalize_opts(opts), do: normalize_attrs(opts)
  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)
end
