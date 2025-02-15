defmodule Ping.Repo.Migrations.AddIdToPings do
  use Ecto.Migration

  def change do
    alter table(:pings) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
    end
  end

end
