defmodule PingWeb.PingChannel do
  use PingWeb, :channel

  alias Ping.Repo
  alias Ping.Pings.Ping
  alias Ping.Accounts.User

  def join("ping:" <> public_id, _params, socket) do
    {:ok, socket |> assign(:public_id, public_id)}
  end

  def handle_in("new_ping", %{"sender_id" => sender_id, "receiver_id" => receiver_id}, socket) do
    with {:ok, sender} <- Repo.get_by(User, public_id: sender_id),
         {:ok, receiver} <- Repo.get_by(User, public_id: receiver_id),
         {:ok, ping} <- Repo.insert(%Ping{sender_id: sender.public_id, receiver_id: receiver.public_id}) do

      PingWeb.Endpoint.broadcast("ping:#{receiver.public_id}", "ping_received", %{
        sender_id: sender.public_id,
        sender_name: sender.username,
        ping_id: ping.id
      })

      {:noreply, socket}
    else
      _ -> {:reply, {:error, "Ping creation failed"}, socket}
    end
  end
end
