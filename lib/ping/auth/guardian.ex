defmodule Ping.Auth.Guardian do
  use Guardian, otp_app: :ping

  alias Ping.Accounts
  alias Ping.Accounts.User

  @impl true
  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, "Invalid user"}

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user!(id) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
