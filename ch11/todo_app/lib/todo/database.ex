defmodule Todo.Database do

  @db_folder "./persist"

  def start_link do
    File.mkdir_p!(@db_folder)
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,                               # ID

      [                                         # PoolArgs
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],

      [@db_folder]                              # WorkerArgs
    )
  end
end
