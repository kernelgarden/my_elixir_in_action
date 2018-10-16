defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start(worker_num) do
    GenServer.start(__MODULE__, worker_num, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end


  def init(worker_num) do
    File.mkdir_p!(@db_folder)

    IO.inspect("initialize database")

    worker_pool = for idx <- 1..worker_num, into: %{} do
      {:ok, worker} = Todo.DatabaseWorker.start(Path.join(@db_folder, to_string(idx)))
      {idx, worker}
    end

    IO.inspect("result: #{worker_pool}")

    {:ok, worker_pool}
  end

  def handle_cast({:store, key, data}, worker_pool) do
    worker = choose_worker(key)
    Todo.DatabaseWorker.store(worker, key, data)
    {:noreply, worker_pool}
  end

  def handle_call({:get, key}, caller, worker_pool) do
    worker = choose_worker(key)
    Todo.DatabaseWorker.get(worker, caller, key)
    {:reply, nil, worker_pool}
  end

  def choose_worker(key) do
    :erlang.phash2(key, 3)
  end
end
