defmodule Learnflow.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :body, :string
    field :message_type, :string, default: "text"
    field :read_at, :utc_datetime_usec

    belongs_to :conversation, Learnflow.Messaging.Conversation
    belongs_to :sender, Learnflow.Accounts.User
    belongs_to :shared_video, Learnflow.Videos.Video

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:conversation_id, :sender_id, :body, :message_type, :shared_video_id, :read_at])
    |> validate_required([:conversation_id, :sender_id, :message_type])
    |> validate_inclusion(:message_type, ["text", "image", "video_share"])
    |> validate_length(:body, max: 5_000)
    |> validate_content()
  end

  defp validate_content(%Ecto.Changeset{} = changeset) do
    type = get_field(changeset, :message_type)
    body = get_field(changeset, :body)
    shared_video_id = get_field(changeset, :shared_video_id)

    cond do
      type == "video_share" and is_nil(shared_video_id) ->
        add_error(changeset, :shared_video_id, "is required")

      type in ["text", "image"] and blank?(body) ->
        add_error(changeset, :body, "can't be blank")

      true ->
        changeset
    end
  end

  defp blank?(value), do: value |> to_string() |> String.trim() == ""
end
