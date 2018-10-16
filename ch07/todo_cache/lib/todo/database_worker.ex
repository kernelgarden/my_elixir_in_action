defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_path) do
    GenServer.start(__MODULE__, db_path)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, caller, key) do
    GenServer.call(pid, {:get, caller, key})
  end


  def init(db_path) do
    File.mkdir_p!(db_path)
    {:ok, db_path}
  end

  def handle_cast({:store, key, data}, db_path) do
    key
    |> file_name(db_path)
    |> File.write!(:erlang.term_to_binary(data))

    IO.inspect("[write] (#{self()}): #{key} - #{data}")

    {:noreply, db_path}
  end

  def handle_call({:get, caller, key}, _, db_path) do
    data = case File.read(file_name(key, db_path)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    IO.inspect("[read] (#{self()}): #{key} - #{data}")
    GenServer.reply(caller, data)

    {:reply, nil, db_path}
  end

  def file_name(key, db_path) do
    Path.join(db_path, to_string(key))
  end
end
