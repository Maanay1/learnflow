defmodule Learnflow.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    field :type, :string, default: "direct"
    field :name, :string
    field :avatar_key, :string
    field :description, :string
    field :max_members, :integer, default: 200

    belongs_to :creator, Learnflow.Accounts.User
    has_many :members, Learnflow.Messaging.ConversationMember
    has_many :messages, Learnflow.Messaging.Message

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:type, :name, :avatar_key, :description, :creator_id, :max_members])
    |> validate_required([:type])
    |> validate_inclusion(:type, ["direct", "group"])
    |> validate_length(:name, max: 100)
    |> validate_length(:avatar_key, max: 255)
    |> validate_length(:description, max: 1_000)
    |> validate_number(:max_members, greater_than: 1, less_than_or_equal_to: 500)
    |> validate_group_name()
  end

  defp validate_group_name(%Ecto.Changeset{changes: %{type: "group"}} = changeset) do
    validate_required(changeset, [:name])
  end

  defp validate_group_name(changeset), do: changeset
end
