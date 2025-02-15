defmodule Ping.Repo.Migrations.AddOnesignalPlayerIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :onesignal_player_id, :string
    end
  end
end
