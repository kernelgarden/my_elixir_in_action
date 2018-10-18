defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_path) do
    IO.puts("Starting DB Worker - #{inspect self()}")
    GenServer.start(__MODULE__, db_path)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
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

  def file_name(key, db_path) do
    Path.join(db_path, to_string(key))
  end
end
