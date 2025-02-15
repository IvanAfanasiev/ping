defmodule PingWeb.SessionController do
  use PingWeb, :controller

  alias Ping.Repo
  alias Ping.Accounts.User
  alias Ping.Auth.Guardian
  alias Ping.Auth.UserToken

  @spec login(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def login(conn, %{"login" => login, "password" => password}) do
    case Repo.get_by(User, login: login) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})

      user ->
        if check_password(user, password) do
          {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {30, :minutes})
          {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :days})
          Repo.insert!(%Ping.Auth.UserToken{
            user_id: Ecto.UUID.cast!(user.id),
            token: refresh_token,
            expires_at: DateTime.add(DateTime.utc_now(), 7 * 24 * 60 * 60, :second)|> DateTime.truncate(:second)
          })
          conn |> json(%{access_token: access_token, refresh_token: refresh_token})
        else
          conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
        end
    end
  end

  defp check_password(user, password) do
    # user.password == password
    Bcrypt.verify_pass(password, user.password)
  end

  def refresh_token(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, _claims} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}),
    %UserToken{} = token <- Repo.get_by(UserToken, token: refresh_token),
    user <- Repo.get(User, token.user_id) do
      Repo.delete!(token)
      {:ok, new_access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {30, :minutes})
      {:ok, new_refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :days})
      Repo.insert!(%Ping.Auth.UserToken{
        user_id: user.id,
        token: new_refresh_token,
        expires_at: DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), 7 * 24 * 60 * 60, :second)
      })

      conn |> json(%{access_token: new_access_token, refresh_token: new_refresh_token})
      else
      _ -> conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
    end
  end

  def logout(conn, %{"refresh_token" => refresh_token}) do
    case Repo.get_by(UserToken, token: refresh_token) do
      nil -> conn |> put_status(:unauthorized) |> json(%{error: "Invalid token"})
      token ->
        Repo.delete!(token)
        conn |> json(%{message: "Logged out"})
    end
  end

end
