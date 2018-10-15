defmodule KeyValueGenServer do
  use GenServer

  def start() do
    GenServer.start(KeyValueGenServer, nil)
  end

  def put(server_pid, key, val) do
    GenServer.cast(server_pid, {:put, key, val})
  end

  def get(server_pid, key) do
    GenServer.call(server_pid, {:get, key})
  end


  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:put, key, val}, state) do
    {:noreply, Map.put(state, key, val)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end
