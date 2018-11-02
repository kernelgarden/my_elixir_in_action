defmodule KeyValue do
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: __MODULE__
    )
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  def init(_) do
    table = :ets.new(
      __MODULE__,
      [:set, :named_table, :public, write_concurrency: true]
    )
    {:ok, table}
  end
end
