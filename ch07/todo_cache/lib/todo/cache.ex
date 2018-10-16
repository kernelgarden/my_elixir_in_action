defmodule Todo.Cache do
  use GenServer

  def start() do
    Todo.Database.start()
    {:ok, server_pid} = GenServer.start(__MODULE__, nil)
    Process.register(server_pid, :todo_cache)
  end

  def server_process(todo_list_name) do
    GenServer.call(:todo_cache, {:server_process, todo_list_name})
  end


  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, todo_server} = GenServer.start(Todo.Server, todo_list_name)
        {
          :reply,
          todo_server,
          Map.put(todo_servers, todo_list_name, todo_server)
        }
    end
  end
end
