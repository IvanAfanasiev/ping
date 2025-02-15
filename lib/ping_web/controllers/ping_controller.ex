defmodule PingWeb.PingController do
  use PingWeb, :controller
  alias Ping.Repo
  alias Ping.Accounts.User
  alias Ping.Pings
  alias Ping.Pings.Ping
  require HTTPoison
  alias PingWeb.WebSocketUserTracker
  import Ecto.Query, only: [from: 2]

    def list(conn, _params) do
      pings = Pings.list_pings()
      json(conn, pings)
    end
    def create(conn, %{"receiver_id" => receiver_id}) do
      # send = get_sender(conn)
      # rec = get_receiver(receiver_id)
      # IO.inspect(send.id, label: "SENDER")
      # IO.inspect(rec.id, label: "RECEIVER")
      with {:ok, receiver} <- get_receiver(receiver_id),
      {:ok, sender} <- get_current_user(conn),
      {:ok, ping} <- save_ping(sender.id, receiver.id) do

        notify_ping_user(receiver, sender)

        conn |> json(%{status: "ok", ping: ping})#sender.id})#ping})
      else
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Receiver not found"})
        {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: "Failed to create ping", details: reason})
      end
    end

    defp get_receiver(receiver_id) do
      case Repo.get_by(User, public_id: receiver_id) do
        nil -> {:error, :not_found}
        receiver -> {:ok, receiver}
      end
    end
    defp get_current_user(conn) do
      case Guardian.Plug.current_resource(conn) do
        nil -> {:error, :unauthorized}
        user -> {:ok, user}
      end
    end
    defp get_by_id(id) do
      case Repo.get_by(User, id: id) do
        nil -> {:error, :not_found}
        user -> {:ok, user}
      end
    end
    defp save_ping(sender_id, receiver_id) do
      IO.inspect(%{sender_id: sender_id, receiver_id: receiver_id, ping: DateTime.truncate(DateTime.utc_now(), :second)})

      sender_id = Ecto.UUID.cast!(sender_id)
      receiver_id = Ecto.UUID.cast!(receiver_id)
      %Ping{}
      |> Ping.changeset(%{sender_id: sender_id, receiver_id: receiver_id, ping: DateTime.truncate(DateTime.utc_now(), :second)})
      |> Repo.insert()
      |> case do
        {:ok, ping} -> {:ok, ping}
        {:error, changeset} -> {:error, Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
      end
    end

    defp translate_error({msg, opts}) do
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end

    defp notify_user(receiver, sender, type) do
      if WebSocketUserTracker.is_online?(receiver.public_id) do
        PingWeb.Endpoint.broadcast("#{type}:#{receiver.public_id}", "#{type}_received", %{
          sender_id: sender.public_id,
          sender_name: sender.username
        })
      else
        send_push_notification(receiver.onesignal_player_id, sender.username)
      end
    end

    defp notify_ping_user(receiver, sender), do: notify_user(receiver, sender, "ping")
    defp notify_pong_user(receiver, sender), do: notify_user(receiver, sender, "pong")


    defp send_push_notification(nil, _sender_name), do: :ok

    defp send_push_notification(player_id, sender_name) do
      payload = %{
        "app_id" => System.get_env("ONE_SIGNAL_APP_ID"),
        "include_player_ids" => [player_id],
        "headings" => %{"en" => "New Ping!"},
        "contents" => %{"en" => "#{sender_name} sent you a ping!"}
      }

      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", System.get_env("PUSH_KEY")}
      ]

      HTTPoison.post("https://onesignal.com/api/v1/notifications", Jason.encode!(payload), headers)
    end

    def update(conn, %{"id" => ping_id}) do
      case Repo.get(Ping, ping_id) do
        nil ->
          conn |> put_status(:not_found) |> json(%{error: "Ping not found"})

        ping ->
          with  {:ok, sender} <- get_by_id(ping.sender_id),
                {:ok, receiver} <- get_current_user(conn) do
            if (receiver.id == ping.receiver_id)
            do
              changeset = Ping.changeset(ping, %{pong: DateTime.truncate(DateTime.utc_now(), :second)})

              case Repo.update(changeset) do
                {:ok, updated_ping} ->
                  json(conn, %{message: "Ping updated", ping: updated_ping})

                {:error, changeset} ->
                  conn |> put_status(:bad_request) |> json(%{error: "Update failed", details: changeset})
              end
              notify_pong_user(receiver, sender)
            else
              conn |> put_status(:forbidden) |> json(%{error: "You are not the receiver of this ping"})
            end
          else
            {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Receiver not found"})
            {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: "Failed to create ping", details: reason})
          end
      end
    end

    def list_recent_pings(conn, _params) do
      with {:ok, current_user} <- get_current_user(conn) do
        IO.inspect(current_user.id, label: "USER")
        IO.inspect(current_user.id, label: "USER")
        query =
          from p in Ping,
            join: u in User,
            on: p.sender_id == u.id or p.receiver_id == u.id,
            where: p.sender_id == ^current_user.id or p.receiver_id == ^current_user.id,
            where: u.public_id != ^current_user.public_id,
            order_by: [desc: p.ping],
            distinct: [
              asc:
                fragment(
                  "LEAST(?, ?) , GREATEST(?, ?)",
                  p.sender_id,
                  p.receiver_id,
                  p.sender_id,
                  p.receiver_id
                )
            ],
            select: %{
              public_id: u.public_id,
              username: u.username,
              last_ping: %{
                id: p.id,
                ping: p.ping,
                pong: p.pong,
                is_sender: (p.sender_id == ^current_user.id)
              },
            }

        users_with_last_ping = Repo.all(query)
        conn |> json(users_with_last_ping)
      else
        {:error, :unauthorized} ->
          conn |> put_status(:unauthorized) |> json(%{error: "Unauthorized"})
      end
    end

end
