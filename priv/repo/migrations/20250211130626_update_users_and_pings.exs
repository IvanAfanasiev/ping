defmodule Ping.Repo.Migrations.CreateUsersAndPings do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :public_id, :string
      add :username, :string
      add :login, :string
      add :password, :string
      add :created_at, :utc_datetime, default: fragment("CURRENT_TIMESTAMP")
      # timestamps()
    end

    create table(:pings, primary_key: false) do
      add :ping, :utc_datetime, default: fragment("CURRENT_TIMESTAMP")
      add :pong, :utc_datetime
      add :sender_id, :uuid
      add :receiver_id, :uuid

      # timestamps()
    end

    create index(:pings, [:sender_id])
    create index(:pings, [:receiver_id])
    # alter table(:pings) do
    #   add :sender_id, references(:users, column: :public_id, on_delete: :nothing)
    #   add :receiver_id, references(:users, column: :public_id, on_delete: :nothing)
    # end
  end
end
