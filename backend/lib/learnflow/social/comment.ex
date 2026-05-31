defmodule Learnflow.Social.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    belongs_to :video, Learnflow.Videos.Video
    belongs_to :user, Learnflow.Accounts.User
    belongs_to :parent, __MODULE__
    has_many :replies, __MODULE__, foreign_key: :parent_id
    field :body, :string
    field :is_deleted, :boolean, default: false
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:video_id, :user_id, :parent_id, :body, :is_deleted])
    |> validate_required([:video_id, :user_id, :body])
    |> validate_length(:body, min: 1, max: 2_000)
  end
end
