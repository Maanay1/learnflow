defmodule Learnflow.Analytics.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_events" do
    field(:event_type, :string)
    field(:metadata, :map, default: %{})
    field(:ip_address, :string)
    field(:user_agent, :string)

    belongs_to(:actor, Learnflow.Accounts.User)
    belongs_to(:target_user, Learnflow.Accounts.User)

    timestamps(updated_at: false, type: :utc_datetime_usec)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:event_type, :actor_id, :target_user_id, :metadata, :ip_address, :user_agent])
    |> validate_required([:event_type])
    |> validate_length(:event_type, max: 80)
    |> validate_length(:ip_address, max: 255)
    |> foreign_key_constraint(:actor_id)
    |> foreign_key_constraint(:target_user_id)
  end
end
