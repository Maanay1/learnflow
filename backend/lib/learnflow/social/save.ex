defmodule Learnflow.Social.Save do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "saves" do
    belongs_to :user, Learnflow.Accounts.User, primary_key: true
    belongs_to :video, Learnflow.Videos.Video, primary_key: true
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(save, attrs) do
    save
    |> cast(attrs, [:user_id, :video_id])
    |> validate_required([:user_id, :video_id])
    |> unique_constraint([:user_id, :video_id], name: :saves_pkey)
  end
end
