defmodule Learnflow.Videos.VideoTag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "video_tags" do
    belongs_to :video, Learnflow.Videos.Video, primary_key: true
    belongs_to :tag, Learnflow.Videos.SubjectTag, primary_key: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(video_tag, attrs) do
    video_tag
    |> cast(attrs, [:video_id, :tag_id])
    |> validate_required([:video_id, :tag_id])
  end
end
