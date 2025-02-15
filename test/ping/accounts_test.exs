defmodule Ping.AccountsTest do
  use Ping.DataCase

  alias Ping.Accounts

  describe "users" do
    alias Ping.Accounts.User

    import Ping.AccountsFixtures

    @invalid_attrs %{username: nil, password: nil, public_id: nil, login: nil, created_at: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "some username", password: "some password", public_id: "some public_id", login: "some login", created_at: ~U[2025-02-09 23:33:00Z]}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.username == "some username"
      assert user.password == "some password"
      assert user.public_id == "some public_id"
      assert user.login == "some login"
      assert user.created_at == ~U[2025-02-09 23:33:00Z]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{username: "some updated username", password: "some updated password", public_id: "some updated public_id", login: "some updated login", created_at: ~U[2025-02-10 23:33:00Z]}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.username == "some updated username"
      assert user.password == "some updated password"
      assert user.public_id == "some updated public_id"
      assert user.login == "some updated login"
      assert user.created_at == ~U[2025-02-10 23:33:00Z]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
