defmodule Ping.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ping.Accounts` context.
  """

  @doc """
  Generate a unique user login.
  """
  def unique_user_login, do: "some login#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique user public_id.
  """
  def unique_user_public_id, do: "some public_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        created_at: ~U[2025-02-09 23:33:00Z],
        login: unique_user_login(),
        password: "some password",
        public_id: unique_user_public_id(),
        username: "some username"
      })
      |> Ping.Accounts.create_user()

    user
  end
end
