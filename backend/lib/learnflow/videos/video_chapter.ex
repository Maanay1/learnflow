defmodule Learnflow.Videos.VideoChapter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "video_chapters" do
    belongs_to :video, Learnflow.Videos.Video
    field :title, :string
    field :start_seconds, :integer
    field :position, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(chapter, attrs) do
    chapter
    |> cast(attrs, [:video_id, :title, :start_seconds, :position])
    |> validate_required([:video_id, :title, :start_seconds, :position])
    |> validate_length(:title, max: 200)
    |> validate_number(:start_seconds, greater_than_or_equal_to: 0)
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
