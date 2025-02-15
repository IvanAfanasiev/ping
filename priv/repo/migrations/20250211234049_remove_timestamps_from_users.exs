defmodule Ping.Repo.Migrations.RemoveTimestampsFromUsers do
  use Ecto.Migration

  def change do
    # alter table(:users) do
    #   remove :inserted_at
    #   remove :updated_at
    # end
    alter table(:pings) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
