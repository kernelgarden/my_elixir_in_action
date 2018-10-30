defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expirity_idle_time :timer.seconds(10)

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def start(list_name) do
    GenServer.start(__MODULE__, list_name)
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

  def via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end

  def init(list_name) do
    # it makes trouble when init called over once
    {:ok,
      {list_name, Todo.Database.get(list_name) || Todo.List.new()},
      @expirity_idle_time
    }
  end

  def handle_cast({:add, entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)

    Todo.Database.store(list_name, new_list)

    {:noreply, {list_name, new_list},
      @expirity_idle_time
    }
  end

  def handle_cast({:update, entry_id, updater_fun}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)

    Todo.Database.store(list_name, new_list)

    {:noreply, {list_name, new_list},
      @expirity_idle_time
    }
  end

  def handle_cast({:update, %{} = new_entry}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, new_entry)

    Todo.Database.store(list_name, new_list)

    {:noreply, {list_name, new_list},
      @expirity_idle_time
    }
  end

  def handle_cast({:delete, entry_id}, {list_name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)

    Todo.Database.store(list_name, new_list)

    {:noreply, {list_name, new_list},
      @expirity_idle_time
    }
  end

  def handle_call({:gets, date}, _, {list_name, todo_list}) do
    {:reply,
      Todo.List.entries(todo_list, date),
      {list_name, todo_list},
      @expirity_idle_time
    }
  end

  def handle_info(:timeout, {list_name, todo_list}) do
    IO.puts("stopped todo server for #{list_name}")
    {:stop, :normal, {list_name, todo_list}}
  end

  def handle_info(unknown_msg, state) do
    IO.puts("received unknown msg: #{unknown_msg}")
    {:noreply, state, @expirity_idle_time}
  end
end
