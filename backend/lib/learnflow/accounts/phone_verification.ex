defmodule Learnflow.Accounts.PhoneVerification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phone_verifications" do
    field(:phone, :string)
    field(:code, :string)
    field(:attempts, :integer, default: 0)
    field(:expires_at, :utc_datetime_usec)
    field(:used, :boolean, default: false)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(verification, attrs) do
    verification
    |> cast(attrs, [:phone, :code, :attempts, :expires_at, :used])
    |> validate_required([:phone, :code, :expires_at])
    |> validate_length(:phone, max: 20)
    |> validate_length(:code, max: 128)
    |> validate_number(:attempts, greater_than_or_equal_to: 0)
  end
end
