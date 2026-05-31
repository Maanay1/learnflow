defmodule Learnflow.Dashboard.PlaylistVideo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "playlist_videos" do
    belongs_to :playlist, Learnflow.Dashboard.Playlist, primary_key: true
    belongs_to :video, Learnflow.Videos.Video, primary_key: true
    field :position, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(playlist_video, attrs) do
    playlist_video
    |> cast(attrs, [:playlist_id, :video_id, :position])
    |> validate_required([:playlist_id, :video_id, :position])
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
