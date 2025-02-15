defmodule PingWeb.UserSocket do
  use Phoenix.Socket

  channel "ping:*", PingWeb.PingChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case Ping.Auth.Guardian.decode_and_verify(token) do
      {:ok, claims} -> {:ok, assign(socket, :user_id, claims["sub"])}
      _ -> :error
    end
  end

  def id(_socket), do: nil
end
