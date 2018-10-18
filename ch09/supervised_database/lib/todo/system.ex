defmodule Todo.System do
  use Supervisor

  @db_worker_num 3

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_) do
    Supervisor.init(
      [{Todo.Database, @db_worker_num}, Todo.Cache],
      strategy: :one_for_one)
  end
end
