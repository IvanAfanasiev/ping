defmodule Ping.Auth do
  alias Ping.Accounts
  alias Ping.Accounts.User
  alias Ping.Auth.Guardian
  alias Bcrypt

  def authenticate_user(login, password) do
    with %User{} = user <- Accounts.get_user_by_login(login),
         true <- Bcrypt.verify_pass(password, user.password) do
      create_token(user)
    else
      _ -> {:error, "Invalid credentials"}
    end
  end

  def create_token(user) do
    case Guardian.encode_and_sign(user) do
      {:ok, token, _claims} -> {:ok, token}
      error -> error
    end
  end

  def verify_token(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} -> Guardian.resource_from_claims(claims)
      error -> error
    end
  end

end
