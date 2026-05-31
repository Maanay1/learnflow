defmodule Learnflow.Dashboard.Playlist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "playlists" do
    belongs_to :user, Learnflow.Accounts.User
    belongs_to :subject_tag, Learnflow.Videos.SubjectTag
    many_to_many :videos, Learnflow.Videos.Video, join_through: Learnflow.Dashboard.PlaylistVideo
    has_many :playlist_videos, Learnflow.Dashboard.PlaylistVideo
    has_many :certificates, Learnflow.Dashboard.Certificate
    field :title, :string
    field :description, :string
    field :slug, :string
    field :difficulty, :string
    field :status, :string, default: "draft"
    field :is_paid, :boolean, default: false
    field :price_cents, :integer, default: 0
    field :thumbnail_key, :string
    field :thumbnail_url, :string, virtual: true
    field :video_count, :integer, virtual: true
    field :duration_seconds, :integer, virtual: true
    field :students_count, :integer, virtual: true
    field :progress, :map, virtual: true
    field :is_public, :boolean, default: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [:user_id, :title, :description, :is_public, :slug, :subject_tag_id, :difficulty, :status, :is_paid, :price_cents, :thumbnail_key])
    |> validate_required([:user_id, :title])
    |> validate_length(:title, max: 200)
    |> validate_length(:slug, max: 220)
    |> validate_length(:description, max: 2_000)
    |> validate_inclusion(:status, ["draft", "published", "archived"])
    |> validate_inclusion(:difficulty, ["beginner", "intermediate", "advanced"], allow_nil: true)
    |> validate_number(:price_cents, greater_than_or_equal_to: 0)
    |> unique_constraint(:slug)
  end
end
