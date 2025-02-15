defmodule Ping.Pings.Ping do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "pings" do
    field :ping, :utc_datetime, default: DateTime.truncate(DateTime.utc_now(), :second)
    field :pong, :utc_datetime

    belongs_to :sender, Ping.Accounts.User, foreign_key: :sender_id, references: :id, type: :binary_id
    belongs_to :receiver, Ping.Accounts.User, foreign_key: :receiver_id, references: :id, type: :binary_id
  end

  def changeset(ping, attrs) do
    ping
    |> cast(attrs, [:sender_id, :receiver_id, :pong])
    |> validate_required([:sender_id, :receiver_id])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:receiver_id)
  end
  defimpl Jason.Encoder, for: Ping.Pings.Ping do
    def encode(%Ping.Pings.Ping{id: id, receiver_id: receiver_id, sender_id: sender_id, ping: ping, pong: pong}, opts) do
      Jason.Encode.map(%{id: id, receiver_id: receiver_id, sender_id: sender_id, ping: ping, pong: pong}, opts)
    end
  end
end
