defmodule Todo.Database do

  @db_worker_num 3
  @db_folder "./persist"

  def start_link do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@db_worker_num, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
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

  def worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {db_worker_path(worker_id), worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp db_worker_path(worker_id) do
    Path.join(@db_folder, to_string(worker_id))
  end

  defp choose_worker(key) do
    :erlang.phash2(key, 3) + 1
  end
end
