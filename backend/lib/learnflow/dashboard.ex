defmodule Learnflow.Dashboard do
  import Ecto.Query
  alias Learnflow.Accounts
  alias Learnflow.Dashboard.{Certificate, Playlist, PlaylistVideo}
  alias Learnflow.Notifications
  alias Learnflow.Payments
  alias Learnflow.Repo
  alias Learnflow.Social
  alias Learnflow.Social.{Comment, Like, Save}
  alias Learnflow.Storage
  alias Learnflow.Videos
  alias Learnflow.Videos.WatchProgress

  @page_size 20

  def get_user_stats(user) do
    %{
      total_watched: Repo.one(from p in WatchProgress, where: p.user_id == ^user.id, select: count()),
      total_completed: Repo.one(from p in WatchProgress, where: p.user_id == ^user.id and p.completed, select: count()),
      current_streak: calculate_streak(user.id),
      followers_count: Social.get_followers_count(user.id),
      following_count: Social.get_following_count(user.id)
    }
  end

  def get_watch_history(user, cursor \\ nil) do
    WatchProgress
    |> where([p], p.user_id == ^user.id and not is_nil(p.last_watched_at))
    |> maybe_cursor(cursor, :last_watched_at)
    |> order_by([p], [desc: p.last_watched_at, desc: p.video_id])
    |> limit(^(@page_size + 1))
    |> preload([video: [:creator, :tags]])
    |> Repo.all()
    |> decorate_progress_videos()
    |> split_page(:last_watched_at, :video_id)
  end

  def delete_history_entry(user, video_id) do
    Repo.delete_all(from p in WatchProgress, where: p.user_id == ^user.id and p.video_id == ^video_id)
    {:ok, :deleted}
  end

  def get_saved_videos(user, cursor \\ nil) do
    Save
    |> where([s], s.user_id == ^user.id)
    |> maybe_cursor(cursor, :inserted_at)
    |> order_by([s], [desc: s.inserted_at, desc: s.video_id])
    |> limit(^(@page_size + 1))
    |> preload([video: [:creator, :tags]])
    |> Repo.all()
    |> decorate_saved_videos()
    |> split_page(:inserted_at, :video_id)
  end

  def calculate_streak(%{id: user_id}), do: calculate_streak(user_id)

  def calculate_streak(user_id) do
    dates =
      Repo.all(
        from p in WatchProgress,
          where: p.user_id == ^user_id and not is_nil(p.last_watched_at),
          select: fragment("date(?)", p.last_watched_at),
          distinct: true,
          order_by: [desc: fragment("date(?)", p.last_watched_at)]
      )

    today = Date.utc_today()

    dates
    |> Enum.with_index()
    |> Enum.take_while(fn {date, index} -> Date.diff(today, date) == index end)
    |> length()
  end

  def export(user) do
    %{
      profile: Accounts.public_user(user),
      watch_history:
        Repo.all(from p in WatchProgress, where: p.user_id == ^user.id)
        |> Enum.map(&Map.take(&1, [:video_id, :seconds_watched, :completed, :last_watched_at, :inserted_at, :updated_at])),
      likes:
        Repo.all(from l in Like, where: l.user_id == ^user.id)
        |> Enum.map(&Map.take(&1, [:video_id, :inserted_at, :updated_at])),
      saves:
        Repo.all(from s in Save, where: s.user_id == ^user.id)
        |> Enum.map(&Map.take(&1, [:video_id, :inserted_at, :updated_at])),
      comments:
        Repo.all(from c in Comment, where: c.user_id == ^user.id)
        |> Enum.map(&Map.take(&1, [:id, :video_id, :parent_id, :body, :is_deleted, :inserted_at, :updated_at])),
      certificates:
        Repo.all(from c in Certificate, where: c.user_id == ^user.id)
        |> Enum.map(&Map.take(&1, [:id, :playlist_id, :certificate_number, :issued_at, :inserted_at, :updated_at]))
    }
  end

  def public_profile(username, viewer_id \\ nil) do
    with user when not is_nil(user) <- Accounts.get_public_user(username) do
      user
      |> Accounts.public_user()
      |> Map.merge(%{
        followers_count: Social.get_followers_count(user.id),
        following_count: Social.get_following_count(user.id),
        videos_count: user.id |> Videos.creator_videos() |> length(),
        is_following: viewer_id && Social.is_following?(viewer_id, user.id)
      })
    end
  end

  def public_videos(user_id, _opts \\ %{}), do: {Videos.creator_videos(user_id), nil}

  def create_course(creator, attrs) do
    attrs = normalize_attrs(attrs)

    course_attrs =
      attrs
      |> Map.put("user_id", creator.id)
      |> Map.put("slug", unique_slug(Map.get(attrs, "title") || "course"))
      |> Map.put("status", "draft")
      |> Map.put_new("is_public", true)

    %Playlist{}
    |> Playlist.changeset(course_attrs)
    |> Repo.insert()
    |> case do
      {:ok, course} -> {:ok, course |> preload_course() |> decorate_course(nil)}
      error -> error
    end
  end

  def update_course(%Playlist{} = course, attrs) do
    attrs = normalize_attrs(attrs) |> Map.drop(["user_id", "slug", "status"])

    course
    |> Playlist.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, course} -> {:ok, course |> preload_course() |> decorate_course(nil)}
      error -> error
    end
  end

  def publish_course(%Playlist{} = course) do
    course
    |> Playlist.changeset(%{"status" => "published", "is_public" => true})
    |> Repo.update()
    |> case do
      {:ok, course} -> {:ok, course |> preload_course() |> decorate_course(nil)}
      error -> error
    end
  end

  def add_video_to_course(%Playlist{} = course, video_id, position) do
    position = to_integer(position || 0)
    now = utc_now()

    Repo.transaction(fn ->
      Repo.update_all(
        from(pv in PlaylistVideo, where: pv.playlist_id == ^course.id and pv.position >= ^position),
        inc: [position: 1],
        set: [updated_at: now]
      )

      %PlaylistVideo{}
      |> PlaylistVideo.changeset(%{playlist_id: course.id, video_id: video_id, position: position})
      |> Repo.insert!(
        on_conflict: [set: [position: position, updated_at: now]],
        conflict_target: [:playlist_id, :video_id]
      )
    end)
  end

  def reorder_course_videos(%Playlist{} = course, ordered_video_ids) when is_list(ordered_video_ids) do
    now = utc_now()

    Repo.transaction(fn ->
      ordered_video_ids
      |> Enum.with_index()
      |> Enum.each(fn {video_id, position} ->
        Repo.update_all(
          from(pv in PlaylistVideo, where: pv.playlist_id == ^course.id and pv.video_id == ^video_id),
          set: [position: position, updated_at: now]
        )
      end)

      :ok
    end)
  end

  def get_course_progress(user_id, course_id) do
    rows =
      Repo.all(
        from pv in PlaylistVideo,
          join: v in assoc(pv, :video),
          left_join: wp in WatchProgress,
          on: wp.video_id == pv.video_id and wp.user_id == ^user_id and wp.completed == true,
          where: pv.playlist_id == ^course_id,
          order_by: [asc: pv.position],
          preload: [video: v],
          select: {pv, not is_nil(wp.video_id)}
      )

    total = length(rows)
    completed = Enum.count(rows, fn {_pv, done?} -> done? end)
    percent = if total == 0, do: 0, else: round(completed * 100 / total)
    next_video = rows |> Enum.find(fn {_pv, done?} -> not done? end) |> case do
      {pv, _} -> pv.video
      nil -> rows |> List.first() |> case do
        {pv, _} -> pv.video
        nil -> nil
      end
    end

    %{completed: completed, total: total, percent: percent, next_video: next_video}
  end

  def check_and_issue_certificate(user_id, course_id) do
    %{completed: completed, total: total} = get_course_progress(user_id, course_id)

    cond do
      total == 0 or completed < total ->
        :not_completed

      certificate = Repo.one(from c in Certificate, where: c.user_id == ^user_id and c.playlist_id == ^course_id) ->
        {:ok, Repo.preload(certificate, [:user, :playlist])}

      true ->
        %Certificate{}
        |> Certificate.changeset(%{
          user_id: user_id,
          playlist_id: course_id,
          certificate_number: certificate_number(),
          issued_at: utc_now()
        })
        |> Repo.insert()
        |> case do
          {:ok, certificate} ->
            Notifications.create_notification(user_id, "course_completed", %{course_id: course_id})
            {:ok, Repo.preload(certificate, [:user, :playlist])}

          {:error, _} -> check_and_issue_certificate(user_id, course_id)
        end
    end
  end

  def generate_certificate_pdf(%Certificate{} = certificate) do
    certificate = Repo.preload(certificate, [:user, :playlist])
    pdf = certificate_pdf(certificate)
    key = "certs/#{certificate.id}.pdf"

    with {:ok, _} <- Storage.put_object(Storage.bucket_certificates(), key, pdf, "application/pdf") do
      Storage.generate_download_url(Storage.bucket_certificates(), key, "learnflow-#{certificate.certificate_number}.pdf")
    end
  end

  def list_courses(opts \\ %{}, user_id \\ nil) do
    opts = normalize_attrs(opts)

    Playlist
    |> where([c], c.status == "published" and c.is_public == true)
    |> maybe_course_filter(:subject_tag_id, Map.get(opts, "subject_tag_id"))
    |> maybe_course_filter(:difficulty, Map.get(opts, "difficulty"))
    |> maybe_price_filter(Map.get(opts, "price"))
    |> order_by([c], [desc: c.inserted_at])
    |> preload([:user, :subject_tag])
    |> Repo.all()
    |> Enum.map(&decorate_course(&1, user_id))
  end

  def get_course_by_slug(slug, user_id \\ nil) do
    Playlist
    |> where([c], c.slug == ^slug and c.status == "published")
    |> preload([:user, :subject_tag, playlist_videos: ^from(pv in PlaylistVideo, order_by: [asc: pv.position], preload: [video: [:creator, :tags]])])
    |> Repo.one()
    |> case do
      nil -> nil
      course -> decorate_course(course, user_id)
    end
  end

  def get_course_by_id(id), do: Repo.get(Playlist, id)

  def creator_course(creator, id) do
    case Repo.get(Playlist, id) do
      %Playlist{user_id: user_id} = course when user_id == creator.id and creator.is_creator -> {:ok, course}
      _ -> {:error, :not_found}
    end
  end

  def my_courses(user) do
    course_ids =
      Repo.all(
        from wp in WatchProgress,
          join: pv in PlaylistVideo,
          on: pv.video_id == wp.video_id,
          join: c in assoc(pv, :playlist),
          where: wp.user_id == ^user.id and c.status == "published",
          distinct: c.id,
          select: c.id
      )

    Repo.all(from c in Playlist, where: c.id in ^course_ids, preload: [:user, :subject_tag])
    |> Enum.map(&decorate_course(&1, user.id))
  end

  def completed_courses_for_video(user_id, video_id) do
    course_ids = Repo.all(from pv in PlaylistVideo, where: pv.video_id == ^video_id, select: pv.playlist_id)

    course_ids
    |> Enum.map(fn course_id ->
      case check_and_issue_certificate(user_id, course_id) do
        {:ok, certificate} ->
          course = certificate.playlist || Repo.get(Playlist, course_id)
          %{course: decorate_course(course, user_id), certificate: certificate}

        :not_completed ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp maybe_cursor(query, nil, _field), do: query
  defp maybe_cursor(query, "", _field), do: query

  defp maybe_cursor(query, cursor, field) do
    case parse_cursor(cursor) do
      nil -> query
      {timestamp, id} -> where(query, [r], field(r, ^field) < ^timestamp or (field(r, ^field) == ^timestamp and field(r, :video_id) < ^id))
    end
  end

  defp split_page(rows, timestamp_field, id_field) do
    page = Enum.take(rows, @page_size)
    next_cursor = if length(rows) > @page_size, do: encode_cursor(List.last(page), timestamp_field, id_field), else: nil
    {page, next_cursor}
  end

  defp decorate_progress_videos(rows) do
    Enum.map(rows, fn row -> %{row | video: Videos.decorate_media_urls(row.video)} end)
  end

  defp decorate_saved_videos(rows) do
    Enum.map(rows, fn row -> %{row | video: Videos.decorate_media_urls(row.video)} end)
  end

  defp encode_cursor(nil, _timestamp_field, _id_field), do: nil
  defp encode_cursor(row, timestamp_field, id_field), do: Base.url_encode64("#{DateTime.to_iso8601(Map.fetch!(row, timestamp_field))}|#{Map.fetch!(row, id_field)}", padding: false)

  defp parse_cursor(cursor) do
    with {:ok, decoded} <- Base.url_decode64(cursor, padding: false),
         [timestamp, id] <- String.split(decoded, "|"),
         {:ok, dt, _} <- DateTime.from_iso8601(timestamp) do
      {dt, id}
    else
      _ -> nil
    end
  end

  defp maybe_course_filter(query, _field, nil), do: query
  defp maybe_course_filter(query, _field, ""), do: query
  defp maybe_course_filter(query, field, value), do: where(query, [c], field(c, ^field) == ^value)

  defp maybe_price_filter(query, "free"), do: where(query, [c], c.is_paid == false)
  defp maybe_price_filter(query, "paid"), do: where(query, [c], c.is_paid == true)
  defp maybe_price_filter(query, _), do: query

  defp decorate_course(nil, _user_id), do: nil

  defp decorate_course(%Playlist{} = course, user_id) do
    stats =
      Repo.one(
        from pv in PlaylistVideo,
          join: v in assoc(pv, :video),
          where: pv.playlist_id == ^course.id,
          select: %{video_count: count(pv.video_id), duration_seconds: coalesce(sum(v.duration_seconds), 0)}
      )

    students_count =
      Repo.one(
        from wp in WatchProgress,
          join: pv in PlaylistVideo,
          on: pv.video_id == wp.video_id,
          where: pv.playlist_id == ^course.id,
          select: count(fragment("DISTINCT ?", wp.user_id))
      )

    thumbnail_url =
      case course.thumbnail_key do
        key when is_binary(key) and key != "" ->
          case Storage.generate_download_url(Storage.bucket_thumbnails(), key, "course-thumbnail") do
            {:ok, url} -> url
            _ -> nil
          end

        _ ->
          nil
      end

    progress = if user_id, do: get_course_progress(user_id, course.id), else: nil
    certificate =
      if user_id && progress && progress.percent == 100 do
        Repo.one(from c in Certificate, where: c.user_id == ^user_id and c.playlist_id == ^course.id)
      end

    Map.merge(course, %{
      video_count: stats.video_count,
      duration_seconds: stats.duration_seconds || 0,
      students_count: students_count,
      thumbnail_url: thumbnail_url,
      progress: progress,
      certificate: certificate,
      access: if(user_id, do: Payments.course_access(%Accounts.User{id: user_id}, course), else: %{has_access: not course.is_paid, is_paid: course.is_paid, price_cents: course.price_cents})
    })
  end

  defp preload_course(course), do: Repo.preload(course, [:user, :subject_tag, :playlist_videos])

  defp unique_slug(title) do
    base =
      title
      |> slugify()
      |> case do
        "" -> "course"
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

  defp certificate_number do
    year = Date.utc_today().year
    random = 4 |> :crypto.strong_rand_bytes() |> Base.encode16(case: :lower)
    "LF-#{year}-#{random}"
  end

  defp certificate_pdf(certificate) do
    user_name = certificate.user.display_name || certificate.user.username
    course_title = certificate.playlist.title
    date = certificate.issued_at |> DateTime.to_date() |> Date.to_iso8601()
    number = certificate.certificate_number

    lines = [
      "JARQ Certificate",
      "Awarded to #{user_name}",
      "For completing #{course_title}",
      "Issued #{date}",
      "Certificate #{number}"
    ]

    text =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, index} -> "BT /F1 18 Tf 72 #{720 - index * 34} Td (#{pdf_escape(line)}) Tj ET" end)
      |> Enum.join("\n")

    objects = [
      "<< /Type /Catalog /Pages 2 0 R >>",
      "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
      "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
      "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
      "<< /Length #{byte_size(text)} >>\nstream\n#{text}\nendstream"
    ]

    build_pdf(objects)
  end

  defp build_pdf(objects) do
    header = "%PDF-1.4\n"

    {body, offsets, _pos} =
      Enum.reduce(Enum.with_index(objects, 1), {"", [], byte_size(header)}, fn {object, index}, {body, offsets, pos} ->
        chunk = "#{index} 0 obj\n#{object}\nendobj\n"
        {body <> chunk, offsets ++ [pos], pos + byte_size(chunk)}
      end)

    xref_pos = byte_size(header <> body)

    xref =
      "xref\n0 #{length(objects) + 1}\n0000000000 65535 f \n" <>
        (offsets |> Enum.map(&("#{String.pad_leading(Integer.to_string(&1), 10, "0")} 00000 n \n")) |> Enum.join())

    trailer = "trailer\n<< /Size #{length(objects) + 1} /Root 1 0 R >>\nstartxref\n#{xref_pos}\n%%EOF\n"
    header <> body <> xref <> trailer
  end

  defp pdf_escape(value) do
    value
    |> to_string()
    |> String.replace("\\", "\\\\")
    |> String.replace("(", "\\(")
    |> String.replace(")", "\\)")
  end

  defp to_integer(value) when is_integer(value), do: value
  defp to_integer(value) when is_binary(value), do: String.to_integer(value)
  defp to_integer(_), do: 0
  defp normalize_attrs(attrs), do: Map.new(attrs || %{}, fn {key, value} -> {to_string(key), value} end)
  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:microsecond)
end
