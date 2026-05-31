defmodule Learnflow.Social.Like do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "likes" do
    belongs_to :user, Learnflow.Accounts.User, primary_key: true
    belongs_to :video, Learnflow.Videos.Video, primary_key: true
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :video_id])
    |> validate_required([:user_id, :video_id])
    |> unique_constraint([:user_id, :video_id], name: :likes_pkey)
  end
end
