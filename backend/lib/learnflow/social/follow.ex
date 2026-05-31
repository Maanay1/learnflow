defmodule Learnflow.Social.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "follows" do
    belongs_to :follower, Learnflow.Accounts.User, primary_key: true
    belongs_to :following, Learnflow.Accounts.User, primary_key: true
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:follower_id, :following_id])
    |> validate_required([:follower_id, :following_id])
    |> check_constraint(:follower_id, name: :follows_no_self_follow_check)
    |> unique_constraint([:follower_id, :following_id], name: :follows_pkey)
  end
end
