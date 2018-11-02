defmodule EtsSimpleRegistry do
  use GenServer

  @reg_tab :ets_registry_table

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def register(target_name) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(@reg_tab, {target_name, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(target_name) do
    case :ets.lookup(@reg_tab, target_name) do
      [{^target_name, proc}] -> proc
      [] -> nil
    end
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(@reg_tab, [:public, :named_table, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    :ets.match_delete(@reg_tab, {:_, pid})
    IO.puts("Dropped pid - #{inspect(pid)}, reason - #{reason}")
    {:noreply, state}
  end
end
