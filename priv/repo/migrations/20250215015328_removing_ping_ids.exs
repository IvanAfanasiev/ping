defmodule Ping.Repo.Migrations.RemovingPingIds do
  use Ecto.Migration

  def change do
    alter table(:pings) do
      remove :sender_id
      remove :receiver_id
    end

    alter table(:pings) do
      add :sender_id, :uuid
      add :receiver_id, :uuid
    end
  end
end
