defmodule Learnflow.Messaging.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "conversation_members" do
    belongs_to :conversation, Learnflow.Messaging.Conversation, primary_key: true
    belongs_to :user, Learnflow.Accounts.User, primary_key: true
    field :role, :string, default: "member"
    field :joined_at, :utc_datetime_usec
    field :last_read_at, :utc_datetime_usec
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:conversation_id, :user_id, :role, :joined_at, :last_read_at])
    |> validate_required([:conversation_id, :user_id, :role])
    |> validate_inclusion(:role, ["admin", "member"])
    |> put_joined_at()
  end

  defp put_joined_at(%Ecto.Changeset{valid?: true} = changeset) do
    case get_field(changeset, :joined_at) do
      nil -> put_change(changeset, :joined_at, DateTime.utc_now() |> DateTime.truncate(:microsecond))
      _ -> changeset
    end
  end

  defp put_joined_at(changeset), do: changeset
end
