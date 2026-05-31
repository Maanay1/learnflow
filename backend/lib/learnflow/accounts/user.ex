defmodule Learnflow.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:phone_verified, :boolean, default: false)
    field(:password_hash, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:display_name, :string)
    field(:avatar_key, :string)
    field(:avatar_url, :string)
    field(:google_id, :string)
    field(:bio, :string)
    field(:is_creator, :boolean, default: false)
    field(:is_verified, :boolean, default: false)
    field(:email_notifications, :boolean, default: true)
    field(:stripe_account_id, :string)
    field(:stripe_onboarding_complete, :boolean, default: false)
    field(:payout_email, :string)
    field(:failed_login_attempts, :integer, default: 0)
    field(:locked_until, :utc_datetime_usec)

    has_many(:sessions, Learnflow.Accounts.Session)
    has_many(:videos, Learnflow.Videos.Video, foreign_key: :creator_id)
    has_many(:playlists, Learnflow.Dashboard.Playlist)
    has_many(:comments, Learnflow.Social.Comment)
    has_many(:notifications, Learnflow.Notifications.Notification)
    has_many(:purchases, Learnflow.Payments.Purchase)
    has_many(:watch_progress_entries, Learnflow.Videos.WatchProgress)
    many_to_many(:liked_videos, Learnflow.Videos.Video, join_through: Learnflow.Social.Like)
    many_to_many(:saved_videos, Learnflow.Videos.Video, join_through: Learnflow.Social.Save)

    timestamps(type: :utc_datetime_usec)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :email,
      :phone,
      :phone_verified,
      :password,
      :display_name,
      :is_creator
    ])
    |> validate_required([:username, :password])
    |> validate_contact()
    |> update_change(:email, &normalize_email/1)
    |> update_change(:phone, &normalize_phone/1)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, allow_nil: true)
    |> validate_format(:phone, ~r/^\+[1-9]\d{7,14}$/,
      message: "must be in E.164 format",
      allow_nil: true
    )
    |> validate_username()
    |> validate_length(:username, min: 3, max: 30)
    |> validate_password_strength()
    |> validate_length(:display_name, max: 100)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> unique_constraint(:phone)
    |> put_password_hash()
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :bio])
    |> validate_length(:display_name, max: 100)
    |> validate_length(:bio, max: 2_000)
  end

  def google_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :display_name, :avatar_url, :google_id, :password_hash, :is_verified])
    |> validate_required([:email, :username, :google_id, :password_hash])
    |> update_change(:email, &normalize_email/1)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_username()
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:display_name, max: 100)
    |> validate_length(:avatar_url, max: 2_000)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> unique_constraint(:google_id)
  end

  def avatar_changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar_key])
    |> validate_length(:avatar_key, max: 255)
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password_strength()
    |> put_password_hash()
  end

  def delete_account_changeset(user) do
    change(user,
      username: "deleted_#{String.slice(user.id, 0, 8)}",
      email: "deleted_#{user.id}@deleted.invalid",
      phone: nil,
      phone_verified: false,
      password_hash: Argon2.hash_pwd_salt(:crypto.strong_rand_bytes(32)),
      display_name: nil,
      bio: nil,
      avatar_key: nil,
      avatar_url: nil,
      google_id: nil,
      is_creator: false,
      is_verified: false
    )
  end

  def validate_username(changeset) do
    validate_format(changeset, :username, ~r/^[A-Za-z0-9_]+$/,
      message: "must contain only letters, numbers, and underscores"
    )
  end

  def validate_password_strength(changeset) do
    changeset
    |> validate_length(:password, min: 8, max: 128)
    |> validate_format(:password, ~r/[A-Za-z]/, message: "must include a letter")
    |> validate_format(:password, ~r/[0-9]/, message: "must include a number")
  end

  defp validate_contact(changeset) do
    email = get_field(changeset, :email)
    phone = get_field(changeset, :phone)

    if blank?(email) and blank?(phone) do
      changeset
      |> add_error(:email, "email or phone is required")
      |> add_error(:phone, "email or phone is required")
    else
      changeset
    end
  end

  defp normalize_phone(value) do
    normalized =
      value
      |> to_string()
      |> String.trim()
      |> String.replace(~r/[^\d+]/, "")

    if normalized == "", do: nil, else: normalized
  end

  defp normalize_email(value) do
    normalized = value |> to_string() |> String.trim() |> String.downcase()
    if normalized == "", do: nil, else: normalized
  end

  defp blank?(value), do: value in [nil, ""]

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
