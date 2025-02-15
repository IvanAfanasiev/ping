defmodule Ping.Repo do
  use Ecto.Repo,
    otp_app: :ping,
    adapter: Ecto.Adapters.Postgres
end
