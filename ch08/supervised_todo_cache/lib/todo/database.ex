defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start(worker_num) do
    GenServer.start(__MODULE__, worker_num, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(worker_num) do
    File.mkdir_p!(@db_folder)

    IO.puts("Starting DB Server")

    worker_pool = for idx <- 1..worker_num, into: %{} do
      {:ok, worker} = Todo.DatabaseWorker.start(Path.join(@db_folder, to_string(idx)))
      {idx, worker}
    end

    {:ok, worker_pool}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, worker_pool) do
    worker = Map.get(worker_pool, :erlang.phash2(key, 3) + 1)
    {:reply, worker, worker_pool}
  end
end
