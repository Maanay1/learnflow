defmodule Learnflow.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @languages ~w(ru en ky es fr de zh)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "videos" do
    belongs_to :creator, Learnflow.Accounts.User
    many_to_many :tags, Learnflow.Videos.SubjectTag,
      join_through: Learnflow.Videos.VideoTag,
      join_keys: [video_id: :id, tag_id: :id]
    has_many :chapters, Learnflow.Videos.VideoChapter
    has_many :comments, Learnflow.Social.Comment
    has_many :watch_progress_entries, Learnflow.Videos.WatchProgress
    field :title, :string
    field :description, :string
    field :slug, :string
    field :status, :string, default: "pending"
    field :difficulty, :string
    field :language, :string, default: "ru"
    field :duration_seconds, :integer
    field :thumbnail_key, :string
    field :video_key, :string
    field :view_count, :integer, default: 0
    field :has_subtitles, :boolean, default: false
    field :subtitle_languages, {:array, :string}, default: []
    field :summary, :string
    field :ai_processed_at, :utc_datetime_usec
    field :is_liked, :boolean, virtual: true, default: false
    field :is_saved, :boolean, virtual: true, default: false
    field :view_url, :string, virtual: true
    field :thumbnail_url, :string, virtual: true
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(video, attrs) do
    video
    |> cast(attrs, [
      :creator_id,
      :title,
      :description,
      :slug,
      :status,
      :difficulty,
      :language,
      :duration_seconds,
      :thumbnail_key,
      :video_key,
      :view_count,
      :has_subtitles,
      :subtitle_languages,
      :summary,
      :ai_processed_at
    ])
    |> validate_required([:creator_id, :title, :slug, :status])
    |> validate_length(:title, max: 200)
    |> validate_length(:slug, max: 200)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> validate_inclusion(:status, ~w(pending active rejected deleted))
    |> validate_inclusion(:difficulty, ~w(beginner intermediate advanced), allow_nil: true)
    |> validate_length(:language, max: 10)
    |> validate_inclusion(:language, @languages)
    |> validate_number(:duration_seconds, greater_than_or_equal_to: 0)
    |> validate_number(:view_count, greater_than_or_equal_to: 0)
    |> unique_constraint(:slug)
  end
end
