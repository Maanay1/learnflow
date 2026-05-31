defmodule Learnflow.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    belongs_to :user, Learnflow.Accounts.User
    field :token_hash, :string
    field :ip_address, :string
    field :user_agent, :string
    field :expires_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token_hash, :ip_address, :user_agent, :expires_at])
    |> validate_required([:user_id, :token_hash, :expires_at])
    |> validate_length(:token_hash, min: 32, max: 255)
    |> validate_length(:ip_address, max: 255)
    |> unique_constraint(:token_hash)
  end
end
