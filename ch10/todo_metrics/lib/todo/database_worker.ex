defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_path, worker_id}) do
    IO.puts("Starting DB Worker #{inspect worker_id}")
    GenServer.start_link(__MODULE__, db_path, name: via_tuple(worker_id))
  end

  def start(db_path) do
    IO.puts("Starting DB Worker")
    GenServer.start(__MODULE__, db_path)
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  @impl GenServer
  def init(db_path) do
    File.mkdir_p!(db_path)
    {:ok, db_path}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_path) do
    key
    |> file_name(db_path)
    |> File.write!(:erlang.term_to_binary(data))

    IO.inspect("[write] (#{inspect self()}): #{inspect key} - #{inspect data}")

    {:noreply, db_path}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_path) do
    data = case File.read(file_name(key, db_path)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    IO.inspect("[read] (#{inspect self()}): #{inspect key} - #{inspect data}")

    {:reply, data, db_path}
  end

  defp file_name(key, db_path) do
    Path.join(db_path, to_string(key))
  end

  def via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
