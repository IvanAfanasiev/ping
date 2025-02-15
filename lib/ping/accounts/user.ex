defmodule Ping.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :public_id}
  schema "users" do
    field :public_id, :string
    field :username, :string
    field :login, :string
    field :password, :string
    field :created_at, :utc_datetime
    field :onesignal_player_id, :string
    has_many :sent_ping, Ping.Pings.Ping, foreign_key: :sender_id
    has_many :received_ping, Ping.Pings.Ping, foreign_key: :receiver_id

    # many_to_many :friends, Ping.Accounts.User, join_through: "user_friends", join_keys: [user_id: :public_id, friend_id: :public_id]
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:public_id, :username, :login, :password, :created_at])
    # |> put_change(:public_id, Nanoid.generate(6))
    |> validate_required([:username, :login, :password])
    |> unique_constraint(:login)
    |> put_password_hash()
    |> generate_public_id(attrs)
  end

  defp put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
  defp generate_public_id(changeset, attrs) do
    case Map.get(attrs, "public_id") do
      :nil ->
        change(changeset, public_id: Nanoid.generate(6))

      _ ->
        changeset
    end
  end

  defimpl String.Chars, for: Ping.Accounts.User do
    def to_string(user) do
      "User{id: #{user.id}, public_id: #{user.public_id}, username: #{user.username}, onesignal_player_id: #{user.onesignal_player_id}}"
    end
  end
  defimpl Jason.Encoder, for: Ping.Accounts.User do
    def encode(%Ping.Accounts.User{public_id: public_id, username: username}, opts) do
      Jason.Encode.map(%{public_id: public_id, username: username}, opts)
    end
  end
end
