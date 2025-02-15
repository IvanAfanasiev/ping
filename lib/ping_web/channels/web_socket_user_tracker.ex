defmodule PingWeb.WebSocketUserTracker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def track_user(user_id) do
    GenServer.call(__MODULE__, {:track, user_id})
  end

  def untrack_user(user_id) do
    GenServer.call(__MODULE__, {:untrack, user_id})
  end

  def is_online?(user_id) do
    GenServer.call(__MODULE__, {:is_online, user_id})
  end

  def handle_call({:track, user_id}, _from, state) do
    {:reply, :ok, Map.put(state, user_id, true)}
  end

  def handle_call({:untrack, user_id}, _from, state) do
    {:reply, :ok, Map.delete(state, user_id)}
  end

  def handle_call({:is_online, user_id}, _from, state) do
    {:reply, Map.has_key?(state, user_id), state}
  end
end
