defmodule Ping.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ping.Repo

  alias Ping.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)


  def authenticate_user(login, password) do
    case Repo.get_by(User, login: login) do
      nil ->
        {:error, "Invalid credentials"}

      user ->
        if Bcrypt.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, "Invalid credentials"}
        end
    end
  end

  def get_user_by_public_id(public_id) do
    Repo.get_by(User, public_id: public_id)
  end

  def get_user_by_login(login) do
    Repo.get_by(User, login: login)
  end

  def search_users_by_public_id(query) do
    from(u in Ping.Accounts.User,
      where: ilike(u.public_id, ^"%#{query}%"),
      select: %{public_id: u.public_id, username: u.username}
    )
    |> Ping.Repo.all()
  end

  def get_user_with_friends(public_id) do
    Ping.Accounts.User
    |> where([u], u.public_id == ^public_id)
    |> join(:left, [u], f in assoc(u, :friends))
    |> preload(:friends)
    |> Ping.Repo.one()
    |> case do
      nil -> []
      user -> user.friends
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
