defmodule Todo.Cache do
  use GenServer

  @db_worker_num 3

  def start() do
    Todo.Database.start(@db_worker_num)
    {:ok, server_pid} = GenServer.start(__MODULE__, nil)
    Process.register(server_pid, :todo_cache)
  end

  def start_link(_) do
    IO.puts("Starting Todo Cache")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end


  def init(_) do
    Todo.Database.start_link(@db_worker_num)
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, todo_server} = Todo.Server.start_link(todo_list_name)
        {
          :reply,
          todo_server,
          Map.put(todo_servers, todo_list_name, todo_server)
        }
    end
  end
end
