defmodule Learnflow.Dashboard.Certificate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "certificates" do
    belongs_to :user, Learnflow.Accounts.User
    belongs_to :playlist, Learnflow.Dashboard.Playlist
    field :issued_at, :utc_datetime_usec
    field :certificate_number, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(certificate, attrs) do
    certificate
    |> cast(attrs, [:user_id, :playlist_id, :certificate_number, :issued_at])
    |> validate_required([:user_id, :playlist_id, :certificate_number])
    |> validate_length(:certificate_number, max: 50)
    |> unique_constraint(:certificate_number)
  end
end
