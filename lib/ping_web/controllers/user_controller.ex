defmodule PingWeb.UserController do
  use PingWeb, :controller
  alias Ping.Accounts
  alias Ping.Accounts.User
  alias Ping.Repo

    def index(conn, _params) do
        user = Guardian.Plug.current_resource(conn)
        json(conn, user)
    end

    def register(conn, %{"username" => username, "login" => login, "password" => password}) do
      case Repo.get_by(User, login: login) do
        nil ->
          conn
          |> put_status(:created)
          |> json(%{success: "Done! ", details: "#{login} has been registered"})
        user ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to create user", details: "Login #{user.login} is already taken"})
          raise "Login #{user.login} is already taken"
      end

      case Ping.Accounts.create_user(%{username: username, login: login, password: password}) do
        {:ok, user} ->
          {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, %{token_type: "access", ttl: {30, :minutes}})
          {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, %{token_type: "refresh", ttl: {7, :days}})
          conn
          |> put_status(:created)
          |> json(%{message: "User created", access_token: access_token, refresh_token: refresh_token, user: %{public_id: user.public_id, username: user.username}})

        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Failed to create user", details: changeset})
      end
    end


    def list(conn, _params) do
      users = Accounts.list_users()
      json(conn, users)
    end

    def findOne(conn, %{"public_id"=>public_id}) do
        case Accounts.get_user_by_public_id(public_id) do
        nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "User not found"})

        user ->
            json(conn, %{
            # id: user.id,
            public_id: user.public_id,
            username: user.username,
            #login: user.login,
            #created_at: user.created_at
            })
        end
    end

    def update_onesignal_id(conn, %{"onesignal_player_id" => player_id}) do
      public_id = Guardian.Plug.current_resource(conn).public_id
      case Accounts.get_user_by_public_id(public_id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "User not found"})
        user ->
          user
          |> Ecto.Changeset.change(%{onesignal_player_id: player_id})
          |> Repo.update()

          conn |> json(%{status: "ok"})
      end
    end

    def search_users(conn, %{"query" => query}) do
      users = Ping.Accounts.search_users_by_public_id(query)
      json(conn, users)
    end

    def update(conn, params) do
      user = Guardian.Plug.current_resource(conn)

      case Ping.Accounts.update_user(user, params) do
        {:ok, updated_user} ->
          json(conn, %{message: "User updated", user: %{public_id: updated_user.public_id, username: updated_user.username}})

        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Update failed", details: changeset})
      end
    end

end
