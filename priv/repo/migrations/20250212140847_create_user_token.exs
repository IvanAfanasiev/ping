defmodule Ping.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :user_id, :uuid, references(:users, type: :uuid, on_delete: :delete_all)
      add :token, :text, null: false
      add :expires_at, :utc_datetime, null: false

    end
  end
end
