defmodule Todo.Server do
  use GenServer

  def start() do
    {:ok, server_pid} = GenServer.start(__MODULE__, nil)
    server_pid
  end

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add, entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    GenServer.cast(server_pid, {:update, entry_id, updater_fun})
  end

  def update_entry(server_pid, %{} = new_entry) do
    GenServer.cast(server_pid, {:update, new_entry})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete, entry_id})
  end

  def entries(server_pid, date) do
    GenServer.call(server_pid, {:gets, date})
  end

  def init(_) do
    {:ok, Todo.List.new()}
  end

  def handle_cast({:add, entry}, state) do
    {:noreply, Todo.List.add_entry(state, entry)}
  end

  def handle_cast({:update, entry_id, updater_fun}, state) do
    {:noreply, Todo.List.update_entry(state, entry_id, updater_fun)}
  end

  def handle_cast({:update, %{} = new_entry}, state) do
    {:noreply, Todo.List.update_entry(state, new_entry)}
  end

  def handle_cast({:delete, entry_id}, state) do
    {:noreply, Todo.List.delete_entry(state, entry_id)}
  end

  def handle_call({:gets, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end
