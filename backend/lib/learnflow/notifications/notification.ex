defmodule Learnflow.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @types ~w(new_follower video_liked video_commented comment_replied new_video_from_followed course_completed)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    belongs_to :user, Learnflow.Accounts.User
    belongs_to :actor, Learnflow.Accounts.User
    belongs_to :video, Learnflow.Videos.Video
    belongs_to :course, Learnflow.Dashboard.Playlist
    belongs_to :comment, Learnflow.Social.Comment
    field :type, :string
    field :read_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :type, :actor_id, :video_id, :course_id, :comment_id, :read_at])
    |> validate_required([:user_id, :type])
    |> validate_inclusion(:type, @types)
  end
end
