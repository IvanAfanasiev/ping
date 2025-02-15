defmodule Ping.Auth.UserToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    # belongs_to :user, Ping.Accounts.User
    field :user_id, Ecto.UUID

  end

  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:token, :expires_at, :user_id])
    |> validate_required([:token, :expires_at, :user_id])
  end
end
