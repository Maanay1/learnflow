defmodule Learnflow.Videos.SubjectTag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subject_tags" do
    field :name, :string
    field :slug, :string
    field :color, :string

    many_to_many :videos, Learnflow.Videos.Video,
      join_through: Learnflow.Videos.VideoTag,
      join_keys: [tag_id: :id, video_id: :id]

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug, :color])
    |> validate_required([:name, :slug])
    |> validate_length(:name, max: 50)
    |> validate_length(:slug, max: 50)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> validate_format(:color, ~r/^#[0-9A-Fa-f]{6}$/)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
