defmodule Learnflow.Videos.WatchProgress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "watch_progress" do
    belongs_to :user, Learnflow.Accounts.User, primary_key: true
    belongs_to :video, Learnflow.Videos.Video, primary_key: true
    field :seconds_watched, :integer, default: 0
    field :completed, :boolean, default: false
    field :last_watched_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(progress, attrs) do
    progress
    |> cast(attrs, [:user_id, :video_id, :seconds_watched, :completed, :last_watched_at])
    |> validate_required([:user_id, :video_id])
    |> validate_number(:seconds_watched, greater_than_or_equal_to: 0)
  end
end
